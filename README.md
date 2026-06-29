# mise-ghcup

A [mise](https://mise.jdx.dev) backend plugin that installs Haskell tools through [GHCup](https://www.haskell.org/ghcup/).

It lets you manage these tools with mise, pinned per project and reproducible across machines:

- `mise-ghcup:ghc` – the Glasgow Haskell Compiler
- `mise-ghcup:hls` – the Haskell Language Server
- `mise-ghcup:stack` – the Stack build tool
- `mise-ghcup:cabal` – the Cabal build tool

## Prerequisites

- mise `2026.6.10` or newer
- The `aqua:ghcup` tool, which provides the `ghcup` binary that this plugin drives. Add it to your `mise.toml` as shown below so mise installs it for you.

## Usage

Add the plugin and the tools to your project's `mise.toml`:

```toml title="mise.toml"
# Minimum required mise version for this plugin.
min_version = "2026.6.10"

[tools]
# Set your preferred versions here:
"aqua:ghcup" = "latest"
"mise-ghcup:ghc" = "latest"
"mise-ghcup:hls" = "latest"
"mise-ghcup:stack" = "latest"
"mise-ghcup:cabal" = "latest"

[plugins]
"vfox:mise-ghcup" = "https://github.com/cprecioso/mise-ghcup.git"

[settings]
# Backend plugins are experimental, so we need to enable them here.
experimental = true
```

Then install everything:

```bash
mise install
```

You can now use the tools, with mise managing the versions:

```bash
ghc --version
cabal --version
```

## Choosing versions

List the versions GHCup offers for any tool:

```bash
mise ls-remote mise-ghcup:ghc
```

Pin a specific version in `mise.toml` instead of `latest`:

```toml
[tools]
"mise-ghcup:ghc" = "9.10.1"
```

## Release channels

By default the plugin only sees GHCup's standard releases. To make extra
[GHCup release channels](https://www.haskell.org/ghcup/guide/#metadata) available
for a tool, set the `channels` option. Each entry is a built-in channel name
(`prereleases`, `vanilla`, or `cross`) or a custom metadata URL, and is merged on
top of the default channel:

```toml
[tools]
# Make prerelease GHCs show up in `ls-remote` and be installable
"mise-ghcup:ghc" = { version = "latest", channels = ["prereleases"] }
```

```bash
mise ls-remote mise-ghcup:ghc   # now includes prerelease versions
```

A single channel can also be given as a plain string (`channels = "prereleases"`).
The channels apply only to the tool they are set on, and don't affect your global
GHCup configuration.

## License

MIT
