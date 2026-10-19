--- Lists the tools this backend provides, for `mise search` and completion
--- Documentation: https://mise.jdx.dev/backend-plugin-development.html#backendlisttools
--- @param ctx BackendListToolsCtx
--- @return BackendListToolsResult
function PLUGIN:BackendListTools(ctx)
    local tools = require("tools")

    return { tools = tools.list() }
end
