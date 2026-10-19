# mise-ghcup

A [mise](https://mise.jdx.dev) backend plugin that installs Haskell tools through [GHCup](https://www.haskell.org/ghcup/).

It lets you manage these tools with mise, pinned per project and reproducible across machines:

- `mise-ghcup:ghc` – the Glasgow Haskell Compiler
- `mise-ghcup:hls` – the Haskell Language Server

> [!NOTE]
>
> These tools are also available, but we don't recommend to install them through GHCup, since they are installable through the Aqua backend, which provides better performance and supply chain safety:
> - `mise-ghcup:stack` – the Stack build tool (just use the `stack` tool instead, will pull from Aqua)
> - `mise-ghcup:cabal` – the Cabal build tool (just use the `cabal` tool instead, will pull from Aqua)

## Prerequisites

- mise `2026.8.8` or newer
- An installed [GHCup](https://www.haskell.org/ghcup/). You can manage it through Mise too, with the `ghcup` tool, by adding it to your `mise.toml` as shown below.

## Usage

Add the plugin and the tools to your project's `mise.toml`:

```toml title="mise.toml"
# Minimum required mise version for this plugin.
min_version = "2026.8.8"

[tools]
# Set your preferred versions here:
"ghcup" = "latest"
"mise-ghcup:ghc" = "latest"
"mise-ghcup:hls" = "latest"

[plugins]
# Pin the plugin to a release tag so every machine runs the same plugin code.
"vfox-backend:mise-ghcup" = "https://github.com/wasp-lang/mise-ghcup.git#v1.0.0"

[settings]
# Backend plugins are experimental, so we need to enable them here.
experimental = true
```

Replace `v1.0.0` with the latest tag from the [releases page](https://github.com/wasp-lang/mise-ghcup/releases).

Then install everything:

```bash
mise install
```

You can now use the tools, with mise managing the versions:

```bash
ghc --version
```

## Choosing versions

List the tools this plugin provides (they also show up in shell completion and the `mise use` picker):

```bash
mise search mise-ghcup:
```

List the versions GHCup offers for any tool:

```bash
mise ls-remote mise-ghcup:ghc
```

Pin a specific version in `mise.toml` instead of `latest`:

```toml
[tools]
"mise-ghcup:ghc" = "9.10.1"
```

## Choosing a channel

By default, versions come from GHCup's default release channel. Set the `channel` option to use a different one. It accepts anything GHCup's `--url-source` does: a predefined channel name (`prereleases`, `cross`, `vanilla`, `default`), a metadata URL, or a file path.

```toml
[tools]
"mise-ghcup:ghc" = { version = "latest", channel = "prereleases" }
```

A channel replaces the default one, so the example above only lists prereleases. Pass a list to combine channels:

```toml
[tools]
"mise-ghcup:ghc" = { version = "latest", channel = ["default", "prereleases"] }
```

## Upgrading the plugin

Change the tag in `mise.toml`, then update the installed plugin to the same tag. mise doesn't re-read the tag once the plugin is installed, so editing `mise.toml` alone has no effect:

```bash
mise plugins update mise-ghcup#v1.1.0
```

## License

MIT
