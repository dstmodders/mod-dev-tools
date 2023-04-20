# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.8.0] - 2023-04-20

### Changed

- Reorder booleans in configurations
- Replace empty values with dashes in data sidebar

### Fixed

- Fix handling of keys in text inputs

### Removed

- Remove "Hide changelog" configuration
- Remove changelog from modinfo

## [0.7.1] - 2023-01-25

### Fixed

- Fix crashing when changing the character

## [0.7.0] - 2020-10-06

### Added

- Add new "Dumped" data sidebar
- Add new "World State" data sidebar

### Changed

- Change "Dump" submenu
- Refactor modinfo

### Fixed

- Fix menu update when selecting player

## [0.6.0] - 2020-09-29

### Added

- Add new "Selected Entity Tags" data sidebar
- Add support for "data_sidebar" in submenu data tables
- Add support for showing the number of data sidebars

### Changed

- Refactor data sidebars

### Fixed

- Fix scroll positioning for data sidebar while switching

## [0.5.0] - 2020-09-23

### Added

- Add new "Select key" configuration
- Add support for scrolling in data sidebar
- Add support for selecting either menu or data sidebar

### Changed

- Improve data sidebar update when selecting entity

### Fixed

- Fix switch data key configuration

## [0.4.1] - 2020-09-21

### Fixed

- Fix crashing related to data loading

## [0.4.0] - 2020-09-21

### Added

- Add "Locale Text Scale" in the front-end data sidebar
- Add "Toggle Locale Text Scale" in "Dev Tools" submenu
- Add new "Dev Tools" submenu
- Add new font option

### Changed

- Refactor data sidebars

## [0.3.0] - 2020-09-20

### Added

- Add new "Switch data key" configuration
- Add support for switching sidebar data

### Changed

- Change some configurations
- Improve overlay sizing and centring

### Fixed

- Fix `d_gettags()` console command

## [0.2.0] - 2020-09-11

### Added

- Add new "Hide changelog" configuration
- Add support for mod API

### Changed

- Enable "Player Vision" submenu on non-admin servers
- Increase the mod loading priority

### Fixed

- Fix crashing when disabling a recipe tab

## 0.1.0 - 2020-09-05

First release.

[unreleased]: https://github.com/dstmodders/mod-dev-tools/compare/v0.8.0...no-sdk
[0.8.0]: https://github.com/dstmodders/mod-dev-tools/compare/v0.7.1...v0.8.0
[0.7.1]: https://github.com/dstmodders/mod-dev-tools/compare/v0.7.0...v0.7.1
[0.7.0]: https://github.com/dstmodders/mod-dev-tools/compare/v0.6.0...v0.7.0
[0.6.0]: https://github.com/dstmodders/mod-dev-tools/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/dstmodders/mod-dev-tools/compare/v0.4.1...v0.5.0
[0.4.1]: https://github.com/dstmodders/mod-dev-tools/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/dstmodders/mod-dev-tools/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/dstmodders/mod-dev-tools/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/dstmodders/mod-dev-tools/compare/v0.1.0...v0.2.0
