# mod-dev-tools

[![CI]](https://github.com/dstmodders/mod-dev-tools/actions/workflows/ci.yml)
[![CD]](https://github.com/dstmodders/mod-dev-tools/actions/workflows/cd.yml)
[![Codecov]](https://codecov.io/gh/dstmodders/mod-dev-tools)

[![Dev Tools](preview.png)](https://steamcommunity.com/sharedfiles/filedetails/?id=2220506640)

## Overview

Mod for the game [Don't Starve Together] which is available through the [Steam
Workshop] to improve the development/testing experience:
https://steamcommunity.com/sharedfiles/filedetails/?id=2220506640

It was inspired by an abandoned _DebugMenuScreen_ withing the game engine and
was designed as an alternative to _debugkeys_.

## Configuration

| Configuration                     | Default          | Description                                                            |
| --------------------------------- | ---------------- | ---------------------------------------------------------------------- |
| **Toggle Tools Key**              | _Right Bracket_  | Key used for toggling the tools                                        |
| **Switch Data Key**               | _X_              | Key used for switching data sidebar                                    |
| **Select Key**                    | _Tab_            | Key used for selecting between menu and data sidebar                   |
| **Movement Prediction Key**       | _Disabled_       | Key used for toggling the movement prediction                          |
| **Pause Key**                     | _P_              | Key used for pausing the game                                          |
| **God Mode Key**                  | _G_              | Key used for toggling god mode                                         |
| **Teleport Key**                  | _T_              | Key used for (fake) teleporting on mouse position                      |
| **Select Entity Key**             | _Z_              | Key used for selecting an entity under mouse                           |
| **Increase Time Scale Key**       | _Page Up_        | Key used to speed up the time scale                                    |
| **Decrease Time Scale Key**       | _Page Down_      | Key used to slow down the time scale                                   |
| **Default Time Scale Key**        | _Home_           | Key used to restore the default time scale                             |
| **Reset Combination**             | _Ctrl + R_       | Key combination used for reloading all mods                            |
| **Default God Mode**              | _Enabled_        | When enabled, enables god mode by default                              |
| **Default Free Crafting Mode**    | _Enabled_        | When enabled, enables crafting mode by default                         |
| **Default Labels Font**           | _Stint Ultra..._ | Which labels font should be used by default?                           |
| **Default Labels Font Size**      | _18_             | Which labels font size should be used by default?                      |
| **Default Selected Labels**       | _Enabled_        | When enabled, show selected labels by default                          |
| **Default Username Labels**       | _Enabled_        | When enabled, shows username labels by default                         |
| **Default Username Labels Mode**  | _Default_        | Which username labels mode should be used by default?                  |
| **Default Forced HUD Visibility** | _Enabled_        | When enabled, forces HUD visibility when "playerhuddirty" event occurs |
| **Default Forced Unfading**       | _Enabled_        | When enabled, forces unfading when "playerfadedirty" event occurs      |
| **Disable Mod Warning**           | _Enabled_        | When enabled, disables the mod warning when starting the game          |
| **Debug**                         | _Disabled_       | When enabled, displays debug data in the console                       |

## Documentation

The [LDoc] documentation generator has been used for generating documentation,
and the most recent version can be found here:
https://docs.dstmodders.com/dev-tools/

- [API](readme/01-api.md)
- [Extending](readme/02-extending.md)

## License

Released under the [MIT License](https://opensource.org/licenses/MIT).

[cd]: https://img.shields.io/github/actions/workflow/status/dstmodders/mod-dev-tools/cd.yml?branch=main&label=cd&logo=github
[ci]: https://img.shields.io/github/actions/workflow/status/dstmodders/mod-dev-tools/ci.yml?branch=main&label=ci&logo=github
[codecov]: https://img.shields.io/codecov/c/github/dstmodders/mod-dev-tools?logo=codecov&token=i1KIj2t9iH
[don't starve together]: https://www.klei.com/games/dont-starve-together
[ldoc]: https://stevedonovan.github.io/ldoc/
[steam workshop]: https://steamcommunity.com/sharedfiles/filedetails/?id=2220506640
