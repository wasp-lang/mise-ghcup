local M = {}

--- @class ToolData
--- @field ghcup_id string The identifier for the tool used by ghcup (e.g "ghc", "cabal", etc)
--- @field binary_name string The name of the tool's main binary (e.g "ghc", "cabal", etc)
--- @field description string Short description shown in `mise search`

---@type table<string, ToolData>
local tools = {
    cabal = {
        ghcup_id = "cabal",
        binary_name = "cabal",
        description = "The Cabal build tool (prefer the `cabal` tool from Aqua)",
    },
    ghc = { ghcup_id = "ghc", binary_name = "ghc", description = "The Glasgow Haskell Compiler" },
    hls = {
        ghcup_id = "hls",
        binary_name = "haskell-language-server-wrapper",
        description = "The Haskell Language Server",
    },
    stack = {
        ghcup_id = "stack",
        binary_name = "stack",
        description = "The Stack build tool (prefer the `stack` tool from Aqua)",
    },
}

--- Lists every supported tool, sorted by name.
--- @return BackendTool[]
M.list = function()
    local list = {}
    for name, tool_data in pairs(tools) do
        table.insert(list, { name = name, description = tool_data.description })
    end
    table.sort(list, function(a, b)
        return a.name < b.name
    end)
    return list
end

--- Asserts that a tool is valid (exists in the tools table).
--- @param tool string
--- @return ToolData
M.assert_valid_tool = function(tool)
    local tool_data = tools[tool]
    if not tool_data then
        error("Tool '" .. tool .. "' not recognized")
    end
    return tool_data
end

return M
