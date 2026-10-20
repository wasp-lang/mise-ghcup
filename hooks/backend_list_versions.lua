--- Lists available versions for a tool in this backend
--- Documentation: https://mise.jdx.dev/backend-plugin-development.html#backendlistversions
--- @param ctx BackendListVersionsCtx
--- @return BackendListVersionsResult
function PLUGIN:BackendListVersions(ctx)
    local ghcup = require("ghcup")
    local version = require("version")
    local strings = require("strings")
    local tools = require("tools")

    local tool = ctx.tool

    local tool_data = tools.assert_valid_tool(tool)
    ghcup.assert_installed(tool_data.ghcup_id)

    -- List available versions
    local output = ghcup.call(tool_data.ghcup_id, "list -t " .. tool_data.ghcup_id .. " -r", ctx.options.channel)

    local versions = {}
    local release_dates = {}
    for _, line in ipairs(strings.split(output, "\n")) do
        line = strings.trim_space(line)
        -- Skip versions ghcup has no binary distribution of for this platform,
        -- since they would fail to install
        if line ~= "" and not (" " .. line .. " "):find("%sno%-bindist%s") then
            -- ghcup list output has version as the 2nd whitespace-delimited field
            local version = line:match("^%S+%s+(%S+)")
            if version then
                table.insert(versions, version)
                -- When ghcup knows the release date, it's the last field, as YYYY-MM-DD.
                -- Older versions have none, so they're reported without one.
                local date = line:match("%s(%d%d%d%d%-%d%d%-%d%d)$")
                if date then
                    release_dates[version] = date .. "T00:00:00Z"
                end
            end
        end
    end

    if #versions == 0 then
        error("No versions found for " .. tool)
    end

    -- Sort ascending (oldest -> newest), as mise expects. We use our own
    -- version comparison because the built-in semver.sort assumes 3-component
    -- versions and mis-orders the 1-to-4-component (PVP) versions these tools use.
    versions = version.sort(versions)

    -- Report release dates so mise can apply minimum_release_age and
    -- `ls-remote --before` to them. Undated versions stay plain strings.
    local result = {}
    for i, v in ipairs(versions) do
        local created_at = release_dates[v]
        if created_at then
            result[i] = { version = v, created_at = created_at }
        else
            result[i] = v
        end
    end

    return { versions = result }
end
