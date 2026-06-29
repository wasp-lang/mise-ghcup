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

--- Normalizes the `channels` option into a list of strings, or nil when unset.
--- Accepts either a single channel string or an array of them.
--- @param channels string|string[]|nil
--- @return string[]|nil
local function normalize_channels(channels)
    if type(channels) == "string" then
        channels = { channels }
    end
    if type(channels) ~= "table" or #channels == 0 then
        return nil
    end
    return channels
end

--- Points ghcup at an isolated config (under this tool's base prefix) whose
--- `url-source` lists the requested release channels on top of ghcup's default
--- metadata. Keeping it isolated avoids touching the user's global ghcup config
--- and makes the result reproducible: the file is rewritten from scratch each
--- call, so removing a channel from `mise.toml` removes it here too.
---
--- ghcup looks for its config in a different place depending on whether it uses
--- XDG-style directories, so we write to (and point it at) whichever location
--- matches the current mode.
--- @param cmd cmd
--- @param base_prefix string
--- @param channels string[] One or more of `prereleases`/`vanilla`/`cross` or a custom metadata URL
--- @param use_xdg_dirs boolean Whether ghcup is running with XDG-style directories
--- @return table env_overrides Extra environment variables ghcup needs to read the config
local function write_channels_config(cmd, base_prefix, channels, use_xdg_dirs)
    local file = require("file")
    local fs = require("fs")

    local config_dir, env_overrides
    if use_xdg_dirs then
        -- XDG mode: ghcup reads $XDG_CONFIG_HOME/ghcup/config.yaml
        local config_home = file.join_path(base_prefix, "xdg-config")
        config_dir = file.join_path(config_home, "ghcup")
        env_overrides = { XDG_CONFIG_HOME = config_home }
    else
        -- Default mode: ghcup reads $GHCUP_INSTALL_BASE_PREFIX/.ghcup/config.yaml
        config_dir = file.join_path(base_prefix, ".ghcup")
        env_overrides = {}
    end
    fs.mkdir_p(cmd, config_dir)

    -- `GHCupURL` is ghcup's built-in default metadata; each extra channel is
    -- merged on top of it, matching `ghcup config add-release-channel`.
    local lines = { "url-source:", "- GHCupURL" }
    for _, channel in ipairs(channels) do
        table.insert(lines, "- " .. channel)
    end

    local config_path = file.join_path(config_dir, "config.yaml")
    local handle = assert(io.open(config_path, "w"))
    handle:write(table.concat(lines, "\n") .. "\n")
    handle:close()

    return env_overrides
end

--- Locate the local ghcup binary and environment variables.
--- @param ghcup_id string The ghcup id whose isolated home to use
--- @param args string
--- @param opts? { channels?: string|string[] } Optional ghcup release channels to enable
--- @return string ghcup_bin, table ghcup_env
function M.call(ghcup_id, args, opts)
    local cmd = require("cmd")
    local fs = require("fs")

    local base_prefix = install_base_prefix(ghcup_id)
    fs.mkdir_p(cmd, base_prefix)

    local env = {
        GHCUP_INSTALL_BASE_PREFIX = base_prefix,
        GHCUP_USE_XDG_DIRS = "0",
    }

    local channels = normalize_channels(opts and opts.channels)
    if channels then
        local overrides = write_channels_config(cmd, base_prefix, channels, env.GHCUP_USE_XDG_DIRS ~= nil)
        for key, value in pairs(overrides) do
            env[key] = value
        end
    end

    return cmd.exec("ghcup " .. args, { env = env })
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
