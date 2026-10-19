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

return M
