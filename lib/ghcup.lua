local M = {}

--- Locate the local ghcup binary and environment variables.
--- @param args string
--- @return string ghcup_bin, table ghcup_env
function M.call(args)
    local cmd = require("cmd")

    return cmd.exec("ghcup " .. args, {
        env = {
            GHCUP_INSTALL_BASE_PREFIX = RUNTIME.pluginDirPath,
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
    local is_windows = RUNTIME.osType == "windows"

    if is_windows then
        local ghcup_path = cmd.exec("where ghcup")
        log.debug("ghcup path: " .. ghcup_path)
    else
        local ghcup_path = cmd.exec("which ghcup")
        log.debug("ghcup path: " .. ghcup_path)
    end
end

return M
