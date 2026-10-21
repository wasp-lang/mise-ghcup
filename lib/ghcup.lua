local M = {}

local is_windows = RUNTIME.osType == "windows"

--- Each tool gets its own ghcup home. Separating the base dir allows parallel
--- installs without race conditions.
--- On Windows, we use a short base since GHC has deeply-nested files that might
--- exceed the 260-char MAX_PATH limit. Elsewhere, we keep it inside the plugin
--- cache dir, so it stays out of the plugin's source checkout.
---
--- @param ghcup_id string The ghcup id of the tool (e.g. "ghc", "cabal")
--- @return string
local function install_base_prefix(ghcup_id)
    local file = require("file")
    if is_windows then
        return "C:\\" .. ghcup_id
    else
        return file.join_path(RUNTIME.cacheDirPath, ghcup_id)
    end
end

--- Builds the `--url-source` flag for a release channel, if set.
--- A channel is anything ghcup accepts as a url source: a predefined channel
--- name (e.g. "prereleases"), a metadata URL, or a file path. A list of them
--- combines their versions, e.g. { "default", "prereleases" }.
---
--- @param channel string|string[]|nil
--- @return string flag The flag, referencing `MISE_GHCUP_URL_SOURCE`
--- @return string? url_source The value for `MISE_GHCUP_URL_SOURCE`
local function url_source_flag(channel)
    local shell = require("shell")

    if channel == nil then
        return "", nil
    end

    if type(channel) == "table" then
        channel = "[" .. table.concat(channel, ",") .. "]"
    elseif type(channel) ~= "string" then
        error("The 'channel' option must be a string or a list of strings")
    end

    return "--url-source " .. shell.var("MISE_GHCUP_URL_SOURCE") .. " ", channel
end

--- Locate the local ghcup binary and environment variables.
--- @param ghcup_id string The ghcup id whose isolated home to use
--- @param args string Arguments, which can reference `env` entries through `shell.var`
--- @param channel string|string[]|nil Release channel(s) to use instead of the default
--- @param env? table<string, string> Extra environment variables for the command
--- @return string
function M.call(ghcup_id, args, channel, env)
    local cmd = require("cmd")
    local fs = require("fs")

    local base_prefix = install_base_prefix(ghcup_id)
    fs.mkdir_p(cmd, base_prefix)

    local flag, url_source = url_source_flag(channel)

    local cmd_env = {
        GHCUP_INSTALL_BASE_PREFIX = base_prefix,
        MISE_GHCUP_URL_SOURCE = url_source,
    }
    for key, value in pairs(env or {}) do
        cmd_env[key] = value
    end

    return cmd.exec("ghcup " .. flag .. args, { env = cmd_env })
end

--- Checks if ghcup is installed by trying to call it with `--version`.
--- @param ghcup_id string The ghcup id whose isolated home to use
--- @return boolean
function M.is_installed(ghcup_id)
    local success, _ = pcall(function()
        return M.call(ghcup_id, "--version")
    end)

    return success
end

--- Asserts that ghcup is installed by trying to call it with `--version`.
--- @param ghcup_id string The ghcup id whose isolated home to use
function M.assert_installed(ghcup_id)
    if not M.is_installed(ghcup_id) then
        error("ghcup is not installed")
    end

    local cmd = require("cmd")
    local log = require("log")

    if is_windows then
        local ghcup_path = cmd.exec("where ghcup")
        log.debug("ghcup path: " .. ghcup_path)
    else
        local ghcup_path = cmd.exec("which ghcup")
        log.debug("ghcup path: " .. ghcup_path)
    end
end

--- @class GhcupListEntry
--- @field version string
--- @field release_date string? As YYYY-MM-DD, when ghcup knows it
--- @field no_bindist boolean Whether there's no binary for the current platform

--- Parses a line of `ghcup list -r` output.
--- Each line is `tool version tags notes`, space-separated, where tags and notes
--- are comma-separated lists that may be empty. The notes (release date,
--- `no-bindist`, ...) have no fixed position, so we look at every token.
--- @param line string
--- @return GhcupListEntry? entry `nil` if the line has no version
function M.parse_list_line(line)
    local version, rest = line:match("^%s*%S+%s+(%S+)(.*)$")
    if not version then
        return nil
    end

    local entry = { version = version, no_bindist = false }
    for token in rest:gmatch("[^%s,]+") do
        if token == "no-bindist" then
            entry.no_bindist = true
        elseif token:match("^%d%d%d%d%-%d%d%-%d%d$") then
            entry.release_date = token
        end
    end

    return entry
end

return M
