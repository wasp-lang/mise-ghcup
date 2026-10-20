local M = {}

local is_windows = RUNTIME.osType == "windows"

--- Create a directory and all parent directories.
--- @param cmd cmd
--- @param path string
function M.mkdir_p(cmd, path)
    local file = require("file")
    local shell = require("shell")
    if is_windows then
        if not file.exists(path) then
            cmd.exec("mkdir " .. shell.var("DIR"), { env = { DIR = path } })
        end
    else
        cmd.exec("mkdir -p " .. shell.var("DIR"), { env = { DIR = path } })
    end
end

--- Whether Windows long path support (`LongPathsEnabled`) is turned on, which
--- lifts the 260-char MAX_PATH limit. Always false on other platforms.
--- @param cmd cmd
--- @return boolean
function M.long_paths_enabled(cmd)
    if not is_windows then
        return false
    end

    local ok, output = pcall(function()
        return cmd.exec("reg query HKLM\\SYSTEM\\CurrentControlSet\\Control\\FileSystem /v LongPathsEnabled")
    end)
    if not ok or output == nil then
        return false
    end

    local value = output:match("LongPathsEnabled%s+REG_DWORD%s+0x(%x+)")
    return value ~= nil and tonumber(value, 16) ~= 0
end

return M
