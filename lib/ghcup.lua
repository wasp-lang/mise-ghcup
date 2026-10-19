local M = {}

local is_windows = RUNTIME.osType == "windows"

--- Each tool gets its own ghcup home. Separating the base dir allows parallel
--- installs without race conditions.
--- On Windows, we use a short base since GHC has deeply-nested files that might
--- exceed the 260-char MAX_PATH limit. Elsewhere, we keep it inside the plugin
--- dir to stay self-contained.
---
--- @param ghcup_id string The ghcup id of the tool (e.g. "ghc", "cabal")
--- @return string
local function install_base_prefix(ghcup_id)
    local file = require("file")
    if is_windows then
        return "C:\\" .. ghcup_id
    else
        return file.join_path(RUNTIME.pluginDirPath, ghcup_id)
    end
end

--- Builds the `--url-source` flag for a release channel, if set.
--- A channel is anything ghcup accepts as a url source: a predefined channel
--- name (e.g. "prereleases"), a metadata URL, or a file path. A list of them
--- combines their versions, e.g. { "default", "prereleases" }.
---
--- @param channel string|string[]|nil
--- @return string
local function url_source_flag(channel)
    if channel == nil then
        return ""
    end

    if type(channel) == "table" then
        channel = "[" .. table.concat(channel, ",") .. "]"
    elseif type(channel) ~= "string" then
        error("The 'channel' option must be a string or a list of strings")
    end

    return '--url-source "' .. channel .. '" '
end

--- Locate the local ghcup binary and environment variables.
--- @param ghcup_id string The ghcup id whose isolated home to use
--- @param args string
--- @param channel string|string[]|nil Release channel(s) to use instead of the default
--- @return string
function M.call(ghcup_id, args, channel)
    local cmd = require("cmd")
    local fs = require("fs")

    local base_prefix = install_base_prefix(ghcup_id)
    fs.mkdir_p(cmd, base_prefix)

    return cmd.exec("ghcup " .. url_source_flag(channel) .. args, {
        env = {
            GHCUP_INSTALL_BASE_PREFIX = base_prefix,
        },
    })
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

return M
