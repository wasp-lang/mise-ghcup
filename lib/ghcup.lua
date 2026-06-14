local M = {}

local is_windows = RUNTIME.osType == "windows"

--- ghcup stages isolated installs under `<base>/ghcup/tmp/...`, re-appending the
--- full destination path beneath it. On Windows that doubled path, combined with
--- GHC's deeply-nested Haddock docs, blows past the 260-char MAX_PATH limit and
--- `CopyFile` fails. Keep the base prefix short on Windows so the staging path
--- stays under the limit. Elsewhere keep it inside the plugin dir to stay
--- self-contained.
--- @return string
local function install_base_prefix()
    if is_windows then
        return "C:\\ghcup"
    end
    return RUNTIME.pluginDirPath
end

--- Locate the local ghcup binary and environment variables.
--- @param args string
--- @return string ghcup_bin, table ghcup_env
function M.call(args)
    local cmd = require("cmd")
    local fs = require("fs")

    local base_prefix = install_base_prefix()
    fs.mkdir_p(cmd, base_prefix)

    return cmd.exec("ghcup " .. args, {
        env = {
            GHCUP_INSTALL_BASE_PREFIX = base_prefix,
            GHCUP_USE_XDG_DIRS = "0",
        },
    })
end

--- Checks if ghcup is installed by trying to call it with `--version`.
--- @return boolean
function M.is_installed()
    local success, _ = pcall(function()
        return M.call("--version")
    end)

    return success
end

--- Asserts that ghcup is installed by trying to call it with `--version`.
function M.assert_installed()
    if not M.is_installed() then
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
