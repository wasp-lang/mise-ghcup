# Changelog

## [3.0.0](https://github.com/wasp-lang/mise-ghcup/compare/v2.0.0...v3.0.0) (2026-10-21)


### ⚠ BREAKING CHANGES

* store GHCup home in the plugin cache dir ([#34](https://github.com/wasp-lang/mise-ghcup/issues/34))

### Features

* report GHCup tags as version aliases ([#35](https://github.com/wasp-lang/mise-ghcup/issues/35)) ([36146a6](https://github.com/wasp-lang/mise-ghcup/commit/36146a60a0bce0145b9fcd41ac5dd4d136b93915))
* store GHCup home in the plugin cache dir ([#34](https://github.com/wasp-lang/mise-ghcup/issues/34)) ([b8e0656](https://github.com/wasp-lang/mise-ghcup/commit/b8e06563146d3ea9e383dba303444559f37d9ec4))

## [2.0.0](https://github.com/wasp-lang/mise-ghcup/compare/v1.1.1...v2.0.0) (2026-10-20)


### ⚠ BREAKING CHANGES

* requires mise 2026.10.15 or newer

### Features

* report version release dates for minimum_release_age ([#28](https://github.com/wasp-lang/mise-ghcup/issues/28)) ([33cb62e](https://github.com/wasp-lang/mise-ghcup/commit/33cb62eeeaa93ec76fe1fcb319415a92bbee6aa1))

## [1.1.1](https://github.com/wasp-lang/mise-ghcup/compare/v1.1.0...v1.1.1) (2026-10-20)


### Bug Fixes

* detect no-bindist anywhere in ghcup list notes ([#30](https://github.com/wasp-lang/mise-ghcup/issues/30)) ([c225ac2](https://github.com/wasp-lang/mise-ghcup/commit/c225ac2bcf1089a02680455f2b65f6b0b7b96ce5))

## [1.1.0](https://github.com/wasp-lang/mise-ghcup/compare/v1.0.0...v1.1.0) (2026-10-19)


### Features

* add `channel` option to choose the GHCup release channel ([#20](https://github.com/wasp-lang/mise-ghcup/issues/20)) ([c8061f2](https://github.com/wasp-lang/mise-ghcup/commit/c8061f2affb12a7f7048de351d8d1728523573a2))
* list provided tools for `mise search` and completion ([#24](https://github.com/wasp-lang/mise-ghcup/issues/24)) ([cf62a2d](https://github.com/wasp-lang/mise-ghcup/commit/cf62a2decbbfdd40e4cc4460233412fe726a5dac))


### Bug Fixes

* hide versions with no binary for the current platform ([#26](https://github.com/wasp-lang/mise-ghcup/issues/26)) ([151ddc5](https://github.com/wasp-lang/mise-ghcup/commit/151ddc5fe80ce0b38dc0b3e7ddec25639415debd))
* omit PATH from exec env when the binary is not found ([#27](https://github.com/wasp-lang/mise-ghcup/issues/27)) ([5ebe670](https://github.com/wasp-lang/mise-ghcup/commit/5ebe6701a3a950f6ff7498dba68d162c824f065c))
* quote paths, versions and channels passed to shell commands ([#25](https://github.com/wasp-lang/mise-ghcup/issues/25)) ([dc9dac5](https://github.com/wasp-lang/mise-ghcup/commit/dc9dac5d3c615409af75ff2dc6fc5796452ab40e))

## [1.0.0](https://github.com/wasp-lang/mise-ghcup/compare/v1.0.0...v1.0.0) (2026-10-19)


### Miscellaneous Chores

* release 1.0.0 ([a4a4e92](https://github.com/wasp-lang/mise-ghcup/commit/a4a4e92eaaa880171475ea01afaa95fed935ad52))
