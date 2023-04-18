# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased][]

### Added

- Add "Hide Ground Overlay" player vision suboption
- Add support for args in the toggle checkbox option
- Add support for pause and time scale keys outside of gameplay

### Changed

- Change author
- Migrate to the new mod SDK
- Rename and restructure some classes

### Removed

- Remove "Hide changelog" configuration
- Remove changelog from modinfo

## [0.7.1][] - 2023-01-25

### Fixed

- Issue with crashing when changing the character

## [0.7.0][] - 2020-10-06

### Added

- Add new "Dumped" data sidebar
- Add new "World State" data sidebar

### Changed

- Change "Dump" submenu
- Refactor modinfo

### Fixed

- Fix issue with menu update when selecting player

## [0.6.0][] - 2020-09-29

### Added

- Add new "Selected Entity Tags" data sidebar
- Add support for "data_sidebar" in submenu data tables
- Add support for showing the number of data sidebars

### Changed

- Refactor data sidebars

### Fixed

- Fix issue with data sidebar scrolling position while switching

## [0.5.0][] - 2020-09-23

### Added

- Add "Select key" configuration
- Add support for selecting either menu or data sidebar
- Add support for the mouse scroll in data sidebar

### Changed

- Improve data sidebar update when selecting entity

### Fixed

- Fix issue with "Switch data key" configuration

## [0.4.1][] - 2020-09-21

### Fixed

- Fix issue with crashing related to data loading

## [0.4.0][] - 2020-09-21

### Added

- Add "Locale Text Scale" in the front-end data sidebar
- Add "Toggle Locale Text Scale" in "Dev Tools" submenu
- Add new "Dev Tools" submenu
- Add new font option

### Changed

- Refactor data sidebars

## [0.3.0][] - 2020-09-20

### Added

- Add "Switch data key" configuration
- Add support for the sidebar data switching

### Changed

- Change some configurations
- Improve overlay sizing and centring

### Fixed

- Fix issue with `d_gettags` console command

## [0.2.0][] - 2020-09-11

### Added

- Add "Hide changelog" configuration
- Add API support

### Changed

- Enable "Player Vision" submenu on non-admin servers
- Increase mod loading priority

### Fixed

- Fix issue with crashing when disabling a recipe tab

## 0.1.0 - 2020-09-05

First release.

[unreleased]: https://github.com/dstmodders/mod-dev-tools/compare/v0.7.1...HEAD
[0.7.1]: https://github.com/dstmodders/mod-dev-tools/compare/v0.7.0...v0.7.1
[0.7.0]: https://github.com/dstmodders/mod-dev-tools/compare/v0.6.0...v0.7.0
[0.6.0]: https://github.com/dstmodders/mod-dev-tools/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/dstmodders/mod-dev-tools/compare/v0.4.1...v0.5.0
[0.4.1]: https://github.com/dstmodders/mod-dev-tools/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/dstmodders/mod-dev-tools/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/dstmodders/mod-dev-tools/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/dstmodders/mod-dev-tools/compare/v0.1.0...v0.2.0
