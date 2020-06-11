# Changelog

All (hopefully) notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
This project <em>does not yet</em> adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) as the API is evolving and MINOR patches may be backwards incompatible.

## [unreleased]
### Added
- CHANGELOG.md
- Matrix observation filters
- Full backtrace in exception notification
- `count` and several other basic default units to Descriptors [#1501]
- Basic Observation::Continuous operators
- Linked new Descriptor form to Task - New descriptor

### Changed
- Updated node packages and changed webpacker configuration
- Progress on fix for [#1420]: CoLDP - Name element columns only getting populated for not valid names
- Made TaxonNameClassification scopes more specific to allow citation ordering (refs [#1040])

### Fixed
- Minor fix in observation matrix dashboard
- Potential fix for `PG::TRDeadlockDetected` when updating taxon name-related data

[#1420]: https://github.com/SpeciesFileGroup/taxonworks/issues/1420
[#1040]: https://github.com/SpeciesFileGroup/taxonworks/issues/1040
[#1501]: https://github.com/SpeciesFileGroup/taxonworks/issues/1501

## [0.12.5] - 2020-06-08
### Added
- Default unit selector for sample character in New Descriptor task ([#1533])
- 'None' option for unit selector in Matrix Row Encoder task
- New Descriptor units

### Changed
- Updated websocket-extensions node package
- Optimized smart selector refresh
- Improved removal error message when source is still in use by some project

### Fixed
- Language selector backend bug
- Sort by page on Citations by Source task ([#1536])
- Removed duplicate `destroy` on project sources controller

[#1533]: https://github.com/SpeciesFileGroup/taxonworks/issues/1533
[#1536]: https://github.com/SpeciesFileGroup/taxonworks/issues/1536

## [0.12.4] - 2020-06-05
### Added
- Pagination on New Observation Matrix task
- Hyperlink to Observation Matrices Dashboard task on New Observation Matrix task (#1532)
- New deletion warning messages on New Observation Matrix task

### Changed
- Renamed New Matrix task to New Observation Matrix
- Citations are now saved without locking on New Taxon Name task
- Updated gems (`bundle update` without altering `Gemfile`)
- Several optimizations on recently used objects retrieval for smart selectors

### Fixed
- Loosing input page numbers when switching tabs on New Taxon Name task

[#1532]: https://github.com/SpeciesFileGroup/taxonworks/issues/1532

## [0.12.3] - 2020-06-04
### Added
- Session storage for biological associations 
### Changed
- When adding people with role picker, they're now added last in the list. ([#1528])
- TODO: document https://github.com/SpeciesFileGroup/taxonworks/commit/efbcc229f1e6dca4e62715bdccf7d4f63b2392c7
- Optimizations on recently used OTUs retrieval for smart selectors
### Fixed
- Delete depiction button on radial annotator
- Preparation type can not be nullifyied on Comprehensive Digitization task. [#1531]

[#1528]: https://github.com/SpeciesFileGroup/taxonworks/issues/1528
[#1531]: https://github.com/SpeciesFileGroup/taxonworks/issues/1531

## [0.12.2] - 2020-06-02
### Added
- stub 
### Changed
- stub 
### Removed 
- stub 

## [0.12.1] - 2020-05-29
### Added
- stub 
### Changed
- stub 
### Removed 
- stub 

## [0.12.0] - 2020-05-15
### Added
- stub 
### Changed
- stub 
### Removed 
- stub 

[unreleased]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.12.5...development
[0.12.5]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.12.4...v0.12.5
[0.12.4]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.12.3...v0.12.4
[0.12.3]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.12.2...v0.12.3
[0.12.2]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.12.1...v0.12.2
[0.12.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.12.0...v0.12.1
[0.12.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.11.0...v0.12.0
