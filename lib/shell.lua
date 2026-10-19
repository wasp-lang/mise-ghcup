local M = {}

local is_windows = RUNTIME.osType == "windows"

--- A double-quoted reference to an environment variable, for building commands
--- that `cmd.exec` runs through `sh -c` (or `cmd /C` on Windows). Pass the value
--- itself in `cmd.exec`'s `env` option, so paths with spaces or shell
--- metacharacters reach the command as a single argument.
--- @param name string The environment variable name
--- @return string
function M.var(name)
    if is_windows then
        return '"%' .. name .. '%"'
    else
        return '"$' .. name .. '"'
    end
end

return M
