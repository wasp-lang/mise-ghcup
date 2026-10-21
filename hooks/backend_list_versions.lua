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
    local tags = {}
    for _, line in ipairs(strings.split(output, "\n")) do
        local entry = ghcup.parse_list_line(line)
        -- Skip versions ghcup has no binary distribution of for this platform,
        -- since they would fail to install
        if entry and not entry.no_bindist then
            table.insert(versions, entry.version)
            -- Older versions have no known release date, so they're reported without one
            if entry.release_date then
                release_dates[entry.version] = entry.release_date .. "T00:00:00Z"
            end
            tags[entry.version] = entry.tags
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

    -- Report GHCup's tags as aliases, so e.g. `recommended` resolves to the
    -- version it points at. When several versions share a tag (`base-*` with
    -- prereleases, or combined channels), the newest one wins.
    -- mise resolves `latest` itself and never asks for it.
    local aliases = {}
    for _, v in ipairs(versions) do
        for _, tag in ipairs(tags[v]) do
            aliases[tag] = v
        end
    end

    return { versions = result, aliases = aliases }
end
