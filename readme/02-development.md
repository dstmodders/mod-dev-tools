# Development

## Overview

_The keywords "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be
interpreted as described in [RFC 2119][]._

This topic has been created for those who are planning to contribute to this
project, so you could easier join into the workflow and for those who are
already contributing to follow the best practices.

- [Quick Start](#quick-start)
- [Environment](#environment)
- [Code Style](#code-style)
- [Workflow](#workflow)

## Quick Start

The easiest and RECOMMENDED way to set up a development environment with most
of the tools already preinstalled is to pull the following [Docker][] image and
incorporate that into your workflow.

To learn more, consider checking out the corresponding [Docker Hub][] image:
[https://hub.docker.com/r/viktorpopkov/dst-mod][]

### Shell/Bash (Linux)

```shell script
$ git clone https://github.com/dstmodders/mod-dev-tools
$ cd ./dst-mod-dev-tools/
$ export DST_MODS="${HOME}/.steam/steam/steamapps/common/Don't Starve Together/mods/"
$ docker pull viktorpopkov/dst-mod
$ docker run --rm -u 'dst-mod' -itv "$(pwd):/mod/" -v "${DST_MODS}:/mods/" viktorpopkov/dst-mod
```

### PowerShell (Windows)

```powershell
PS C:\> git clone https://github.com/dstmodders/mod-dev-tools
PS C:\> cd .\dst-mod-dev-tools\
PS C:\> $Env:DST_MODS = "C:\Program Files (x86)\Steam\steamapps\common\Don't Starve Together\mods\"
PS C:\> docker pull viktorpopkov/dst-mod
PS C:\> docker run --rm -u 'dst-mod' -itv "${PWD}:/mod/" -v "$($Env:DST_MODS):/mods/" viktorpopkov/dst-mod
```

## Environment

### Lua

The game engine uses the [Lua][] interpreter v5.1, so it's RECOMMENDED to use
the same version locally as well. In this project, the v5.1.5 is used so if you
happen to stumble upon on some compatibility issues consider switching to that
version instead.

Also, I RECOMMEND installing the latest [LuaRocks][] to install some tools used
throughout the project as well.

#### Installation (Linux)

##### [Lua][]

```shell script
$ sudo apt install build-essential libreadline-dev
$ curl -R -O http://www.lua.org/ftp/lua-5.1.5.tar.gz
$ tar zxf lua-5.1.5.tar.gz
$ cd lua-5.1.5/
$ make linux test
$ sudo make install
```

##### [LuaRocks][]

```shell script
$ wget https://luarocks.org/releases/luarocks-3.3.1.tar.gz
$ tar zxpf luarocks-3.3.1.tar.gz
$ cd luarocks-3.3.1/
$ ./configure
$ make
$ sudo make install
```

### Tools

The project uses the following tools to improve overall code quality and
encourage following some of the best practices:

- [Busted][]
- [ds-mod-tools][]
- [EditorConfig][]
- [GNU Make][]
- [ktools][]
- [LCOV][]
- [LDoc][]
- [Luacheck][]
- [LuaCov][]
- [Prettier][]

I do RECOMMEND getting familiar with these tools and integrate them into your
workflow when developing this project. Their usage is OPTIONAL but is strongly
advisable. Consider running at least code linting and tests (if there are any)
throughout the development.

#### Installation (Linux)

##### [Busted][], [LDoc][], [Luacheck][] and [LuaCov][]

```shell script
$ sudo luarocks install busted
$ sudo luarocks install ldoc
$ sudo luarocks install luacheck
$ sudo luarocks install luacov
$ sudo luarocks install luacov-console
$ sudo luarocks install luacov-reporter-lcov
$ sudo luarocks install cluacov
```

##### [ds-mod-tools][]

```shell script
$ sudo apt install premake4
$ git clone https://github.com/kleientertainment/ds_mod_tools
$ cd ds_mod_tools/src/
$ ./premake.sh
$ cd ../build/proj/
$ make
```

##### [LCOV][]

```shell script
$ git clone https://github.com/linux-test-project/lcov.git
$ cd lcov/
$ sudo make install
```

##### [Prettier][]

```shell script
$ npm install -g prettier @prettier/plugin-xml
# or
$ yarn global add prettier @prettier/plugin-xml
```

##### [ktools][]

```shell script
$ sudo apt install pkg-config imagemagick=8:6.9.10.23+dfsg-2.1
$ git clone https://github.com/victorpopkov/ktools.git
$ cd ktools/
$ cmake \
    -DImageMagick_Magick++_LIBRARY="$(pkg-config --variable=libdir Magick++)/lib$(pkg-config --variable=libname Magick++).so" \
    -DImageMagick_MagickCore_INCLUDE_DIR="$(pkg-config --cflags-only-I MagickCore | tail -c+3)" \
    -DImageMagick_MagickCore_LIBRARY="$(pkg-config --variable=libdir MagickCore)/lib$(pkg-config --variable=libname MagickCore).so" \
    -DImageMagick_MagickWand_INCLUDE_DIR="$(pkg-config --cflags-only-I MagickWand | tail -c+3)" \
    -DImageMagick_MagickWand_LIBRARY="$(pkg-config --variable=libdir MagickWand)/lib$(pkg-config --variable=libname MagickWand).so" \
    .
$ ./configure
$ make
$ make install
```

## Code Style

In addition to the general code style that is described in the [EditorConfig][]
and some stylistic errors that can be caught by the [Luacheck][], the
[Lua Style Guide][] can be used as a reference throughout the project.

Based on the game engine, the following suggestions SHOULD apply which differ
from the mentioned guide:

- Comments SHOULD neither have a capitalized first letter, nor a trailing dot (unless there are multiple sentences)
- LDoc `@param`, `@tparam` and `@treturn` descriptions SHOULD have a first letter capitalized and no trailing dot
- Use 4 spaces for indention (this is also more consistent between other languages)
- Use PascalCase for classes/modules, functions and methods
- Use snake_case for the class fields and variables

If at some point the mentioned style guide suggests a different approach that
wasn't mentioned earlier use the existing code as a guide instead.

All the suggestions are negotiable and can be changed in the future when a
rational reason has been found.

## Workflow

- [Communication](#communication)
- [Project Management](#project-management)
- [Git](#git)
- [CI/CD](#cicd)
- [Makefile](#makefile)

### Communication

For communication, I RECOMMEND using [Slack][].

### Project Management

For project management, I use [Trello][], the [Agile][] software development
approach along with the [Scrum][] structure.

The board: [https://trello.com/b/3JtDZFJG][]

#### Labels

Each card SHOULD have at least one label:

1. **Bug (Red)**: an engine bug and SHOULD be used only when it was confirmed
2. **Improvement (Blue)**: changes and/or improvements
3. **Infrastructure (Cyan)**: anything related to servers, CI/CD, etc
4. **Issue (Orange)**: a mod issue
5. **New feature (Yellow)**: a new feature
6. **Task (Purple)**: extra work or research is required outside of the repository scope
7. **User story (Green)**: user stories like "As a [persona], I [want to], [so that] ..."

#### Suggestions

You SHOULD follow these rules:

1.  Each card (except user story cards) in the "In Progress" should have at least one member (when there are more than one member in the project)
2.  Each card in the "Ready for QA", "QA" or "Done" should have at least one corresponding commit attached (except user story cards)
3.  Each card name should use the present tense
4.  Each card that doesn't have a member is free to take
5.  Each child card should have a parent card attached to it (user story and task cards shouldn't be referenced by other card types)
6.  Each issue card content should have "Description", "Cause" and "Possible solution" (see the template as an example)
7.  Each issue card name should start with "Fix issue..."
8.  Each parent card shouldn't have any child cards attached to it
9.  Each user story card should follow the "As a [persona], I [want to], [so that]" template
10. Each user story card should have at least one new feature or improvement card
11. Each user story card shouldn't have any members
12. The order of the cards represents the dependability: parent cards should be closer to the top than the child ones
13. The order of the cards represents the priority: closer to the bottom – higher the priority
14. Use existing templates (when possible)
15. You should look through the cards in each column from bottom to top

### Git

#### Branches

While developing, the `master` branch MAY be used for development. However,
after the first release, all development in the public repository MUST be done
in the `develop` branch instead.

Each branch MUST start with the corresponding prefix:

- **Feature**: `feature/`
- **Hotfix**: `hotfix/`
- **Issue**: `issue/`
- **Release**: `release/`

After the prefix, a label as short as possible MUST be used (or MAY be used if
there is a corresponding OPTIONAL card/issue reference number), so we could
differentiate active branches:

- **Feature**: `feature/controller-support`
- **Hotfix**: `hotfix/movement-prediction`
- **Issue**: `issue/sendrpctoserver`
- **Release**: `release/0.1.0`

You can add an OPTIONAL number pointing to the corresponding [Trello][] card
number or [GitHub][] issue (you MUST add a "G" letter before the number:
`issue-G1/`). In this case, the label becomes OPTIONAL:

- **Feature**: `feature-42/controller-support` or `feature-42`
- **Hotfix**: `hotfix-46/movement-prediction` or `hotfix-46`
- **Issue**: `issue-G2/sendrpctoserver` or `issue-G2`

In general, a shorter version without a label is RECOMMENDED when a reference
number is available.

Furthermore, when starting developing a certain feature or fixing a certain
issue you MUST work in a named branch by adding your [GitHub][] username prefix:

- **Feature**: `<your username>/feature-42/controller-support` or `<your username>/feature-42`
- **Hotfix**: `<your username>/hotfix-46/movement-prediction` or `<your username>/hotfix-46`
- **Issue**: `<your username>/issue-G2/sendrpctoserver` or `<your username>/issue-G2`

This not only allows you to work peacefully on a certain feature/issue and no
one will interfere into your work but also allows you not to bother with commits
as in the end they will be rebased into the non-prefixed branch before merging
anyway.

In the end, you MUST just follow this workflow:

1. Create or pick a [Trello][] card or a [GitHub][] issue (Reference example: #42)
2. Create the corresponding branch: `<your username>/issue-42` (from `develop` branch)
3. Review, commit and push your work into your branch
4. Repeat

#### Commits

There are no specific suggestions for commits in this project, so the best bet
would be to look at the previous commits as a source of reference, be consistent
and use common sense.

You MAY follow these rules:

1. Be short and descriptive
2. Capitalize the first letter
3. Describe your changes in an imperative mood as if you are giving orders to the codebase
4. Use the present tense

However, the [Conventional Commits][] specification is currently under
consideration.

### CI/CD

[GitHub Actions][] are used as a [Continuous Integration][] (CI) provider for
running both code linting and tests on every commit and release. The same goes
with the [Continuous Deployment][] (CD) of the latest documentation.

Make sure CI/CD doesn't report any issues and consider fixing them if it does.
However, the CI/CD reports SHOULD only be the last resort as most of the issues
SHOULD be fixed locally either before making any pull requests or pushing into
the repository.

### Makefile

_Currently, only Linux is supported. However, the Windows support has also been
under consideration by incorporating a [CMake][] or [NMake][] equivalents._

This project uses [Makefile][] so the most common tasks have been wrapped inside
the corresponding rules:

```shell script
$ make help
```

```
Please use 'make <target>' where '<target>' is one of:

   citest          to run Busted tests for CI
   dev             to run reinstall + ldoc + lint + test
   gitrelease      to commit modinfo.lua and CHANGELOG.md + add a new tag
   install         to install the mod
   ldoc            to generate an LDoc documentation
   lint            to run code linting
   modicon         to pack modicon
   reinstall       to uninstall and then install the mod
   release         to update version
   test            to run Busted tests
   testclean       to clean up after tests
   testcoverage    to print the tests coverage report
   testlist        to list all existing tests
   uninstall       to uninstall the mod
   workshop        to prepare the Steam Workshop directory + archive
   workshopclean   to clean up Steam Workshop directory + archive
```

[agile]: https://en.wikipedia.org/wiki/Agile_software_development
[busted]: https://olivinelabs.com/busted/
[cmake]: https://cmake.org/
[continuous deployment]: https://en.wikipedia.org/wiki/Continuous_deployment
[continuous integration]: https://en.wikipedia.org/wiki/Continuous_integration
[conventional commits]: https://www.conventionalcommits.org/
[docker hub]: https://hub.docker.com/
[docker]: https://www.docker.com/
[ds-mod-tools]: https://github.com/kleientertainment/ds_mod_tools
[editorconfig]: https://editorconfig.org/
[github actions]: https://github.com/features/actions
[github]: https://github.com/
[gnu make]: https://www.gnu.org/software/make/
[https://hub.docker.com/r/viktorpopkov/dst-mod]: https://hub.docker.com/r/viktorpopkov/dst-mod
[https://trello.com/b/3jtdzfjg]: https://trello.com/b/3JtDZFJG
[ktools]: https://github.com/nsimplex/ktools
[lcov]: http://ltp.sourceforge.net/coverage/lcov.php
[ldoc]: https://stevedonovan.github.io/ldoc/
[lua style guide]: https://github.com/luarocks/lua-style-guide
[lua]: https://www.lua.org/
[luacheck]: https://github.com/mpeterv/luacheck
[luacov]: https://keplerproject.github.io/luacov/
[luarocks]: https://luarocks.org/
[makefile]: https://en.wikipedia.org/wiki/Makefile
[nmake]: https://msdn.microsoft.com/en-us/library/dd9y37ha.aspx
[prettier]: https://prettier.io/
[rfc 2119]: https://www.ietf.org/rfc/rfc2119.txt
[scrum]: https://en.wikipedia.org/wiki/Scrum_(software_development)
[slack]: https://slack.com/
[trello]: https://trello.com/
