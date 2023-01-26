# mod-dev-tools

> **NB!** Branch [no-sdk] is used solely for maintaining purposes before the
> official [v1.0.0] release. It doesn't include all the latest features and/or
> fixes. Consider switching to the [main] branch instead.

[![CI]](https://github.com/dstmodders/mod-dev-tools/actions/workflows/ci.yml)
[![Codecov]](https://codecov.io/gh/dstmodders/mod-dev-tools)

[![Dev Tools]](https://steamcommunity.com/sharedfiles/filedetails/?id=2220506640)

## Overview

Mod for the game [Don't Starve Together][] which is available through the
[Steam Workshop][] to improve the development/testing experience:
https://steamcommunity.com/sharedfiles/filedetails/?id=2220506640

It was inspired by an abandoned _DebugMenuScreen_ withing the game engine and
was designed as an alternative to _debugkeys_.

## Configuration

| Configuration                     | Default          | Description                                              |
| --------------------------------- | ---------------- | -------------------------------------------------------- |
| **Toggle tools key**              | _Right Bracket_  | Key used for toggling the tools                          |
| **Switch data key**               | _X_              | Key used for switching data sidebar                      |
| **Select key**                    | _Tab_            | Key used for selecting between menu and data sidebar     |
| **Movement prediction key**       | _Disabled_       | Key used for toggling the movement prediction            |
| **Pause key**                     | _P_              | Key used for pausing the game                            |
| **God mode key**                  | _G_              | Key used for toggling god mode                           |
| **Teleport key**                  | _T_              | Key used for (fake) teleporting on mouse position        |
| **Select entity key**             | _Z_              | Key used for selecting an entity under mouse             |
| **Increase time scale key**       | _Page Up_        | Key used to speed up the time scale                      |
| **Decrease time scale key**       | _Page Down_      | Key used to slow down the time scale                     |
| **Default time scale key**        | _Home_           | Key used to restore the default time scale               |
| **Reset combination**             | _Ctrl + R_       | Key combination used for reloading all mods              |
| **Default god mode**              | _Enabled_        | When enabled, enables god mode by default                |
| **Default free crafting mode**    | _Enabled_        | When enabled, enables crafting mode by default           |
| **Default labels font**           | _Stint Ultra..._ | Which labels font should be used by default?             |
| **Default labels font size**      | _18_             | Which labels font size should be used by default?        |
| **Default selected labels**       | _Enabled_        | When enabled, show selected labels by default            |
| **Default username labels**       | _Enabled_        | When enabled, shows username labels by default           |
| **Default username labels mode**  | _Default_        | Which username labels mode should be used by default?    |
| **Default forced HUD visibility** | _Enabled_        | When enabled, forces HUD visibility                      |
| **Default forced unfading**       | _Enabled_        | When enabled, forces unfading                            |
| **Disable mod warning**           | _Enabled_        | When enabled, disables the mod warning                   |
| **Hide changelog**                | _Enabled_        | When enabled, hides the changelog in the mod description |
| **Debug**                         | _Disabled_       | When enabled, displays debug data in the console         |

## License

Released under the [MIT License](https://opensource.org/licenses/MIT).

[ci]: https://img.shields.io/github/actions/workflow/status/dstmodders/mod-dev-tools/ci.yml?branch=no-sdk&label=ci
[codecov]: https://img.shields.io/codecov/c/github/dstmodders/mod-dev-tools?token=i1KIj2t9iH
[dev tools]: ./preview.png
[don't starve together]: https://www.klei.com/games/dont-starve-together
[ldoc]: https://stevedonovan.github.io/ldoc/
[main]: https://github.com/dstmodders/mod-dev-tools
[no-sdk]: https://github.com/dstmodders/mod-dev-tools/tree/no-sdk
[steam workshop]: https://steamcommunity.com/sharedfiles/filedetails/?id=2220506640
[trello]: https://trello.com/
[v1.0.0]: https://github.com/dstmodders/mod-dev-tools/releases/tag/v1.0.0
