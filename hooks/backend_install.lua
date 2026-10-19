--- Installs a specific version of a tool
--- Documentation: https://mise.jdx.dev/backend-plugin-development.html#backendinstall
--- @param ctx BackendInstallCtx
--- @return BackendInstallResult
function PLUGIN:BackendInstall(ctx)
    local cmd = require("cmd")
    local fs = require("fs")
    local ghcup = require("ghcup")
    local log = require("log")
    local shell = require("shell")
    local tools = require("tools")

    local tool = ctx.tool
    local version = ctx.version
    local install_path = ctx.install_path

    local tool_data = tools.assert_valid_tool(tool)
    ghcup.assert_installed(tool_data.ghcup_id)

    -- Install the tool
    log.info("Installing " .. tool .. " " .. version .. " to " .. install_path)

    fs.mkdir_p(cmd, install_path)
    ghcup.call(
        tool_data.ghcup_id,
        "install "
            .. tool_data.ghcup_id
            .. " "
            .. shell.var("MISE_GHCUP_VERSION")
            .. " -i "
            .. shell.var("MISE_GHCUP_INSTALL_PATH"),
        ctx.options.channel,
        { MISE_GHCUP_VERSION = version, MISE_GHCUP_INSTALL_PATH = install_path }
    )

    return {}
end
