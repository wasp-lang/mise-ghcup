local M = {}

local is_windows = RUNTIME.osType == "windows"

--- Create a directory and all parent directories.
--- @param cmd cmd
--- @param path string
function M.mkdir_p(cmd, path)
    local file = require("file")
    if is_windows then
        if not file.exists(path) then
            cmd.exec("mkdir " .. path)
        end
    else
        cmd.exec("mkdir -p " .. path)
    end
end

return M
