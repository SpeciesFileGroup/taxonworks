# Changelog

All (hopefully) notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
This project <em>does not yet</em> adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) as the API is evolving and MINOR patches may be backwards incompatible.

## [unreleased]

\-

## [0.12.15] - 2020-08-18

### Fixed
- Sqed hook initiated with String, not Class [#1654]

[#1654]: https://github.com/SpeciesFileGroup/taxonworks/issues/1654

## [0.12.14] - 2020-08-17

### Added
- Help tips in comprehensive specimen digitization task
- Help tips in new source task
- Type section in Browse OTUs task [#1615]
- Automatically filter sections by taxon rank in Browse OTUs task
- Rank string in browse nomenclature
- Pinboard navigator (Ctrl/Alt + G) [#1647]
- Filter by repository in filter collection objects [#1650]
- Hotkey for add element to pinboard (Ctrl/Alt + P)

### Fixed
- Collectors order in comprehensive specimen digitization
- Losses data of etymology form after set a gender
- Autocomplete component not encoding query params properly
- Random RGeo deserialization errors [#1553]

### Changed
- New combination redirect to the valid name [#1639]
- Rename comprehensive specimen digitization task card
- Updated chartkick gem [#1646]
- Improved verbatim date and geographic coordinates recognition
- Improved soft validation messages for coordinated species-group

[#1553]: https://github.com/SpeciesFileGroup/taxonworks/issues/1553
[#1615]: https://github.com/SpeciesFileGroup/taxonworks/issues/1615
[#1639]: https://github.com/SpeciesFileGroup/taxonworks/issues/1639
[#1646]: https://github.com/SpeciesFileGroup/taxonworks/pull/1646
[#1647]: https://github.com/SpeciesFileGroup/taxonworks/issues/1647
[#1650]: https://github.com/SpeciesFileGroup/taxonworks/issues/1650

## [0.12.13] - 2020-08-04

### Added
- Delete confirmation for original combinations [#1618]
- Delete confirmation for type specimens in new type specimen task
- Check if already exist an asserted combination with the same otu and geographic area in new asserted distribution task [#1329]
- Modal on duplicate original citations in radial annotator [#1576]
- Soft validations component for citations in radial annotator and tasks [#1552]
- Redirect to valid name in browse nomenclature [#446]
- sessionStorage for browse nomenclature autocomplete [#446]
- Observation matrices in radial object [#1527]
- Comprehensive task to taxon name radial [#934]
- Map on OTU radial in asserted distribution form [#856]
- Pin objects from list in filter sources
- Checkbox to make document public on list in radial annotator
- Title legend for "make default" icon in pinboard slide
- Checkbox to alternative between AND/OR filter for authors in filter sources
- Lep staged 2 layout for staged images [#1635]

### Changed
- Use amazing_print instead of awesome_print gem
- Cleanup and add spec basis for nomenclature tabular stats queries  
- Improve/unify image modal [#1617]
- Replace repository and source autocompletes for smart selectors in new type material task
- Changed autosave behaviour in new asserted distribution task
- Gender list order in new taxon name task
- Page range soft validation message made less strict
- Original citation-related UI text
- Moved taxon name input search to right column in new taxon name
- Persons autosave in new taxon name
- Updated elliptic node package. [#1632]

### Fixed
- Flip object to subject label on type section in new taxon name task
- Shapes are possible to drag even if this option is not set up
- Columns size of georeference table [#1622]
- Webpacker host and port bind on docker container
- Wrong taxon name relationship soft validation message for genera
- Modal confirmation its not displaying in manage synonyms section [#1627]
- Manage synonyms includes combinations [#1628]
- Recent and per params in source filter and controller
- Missing ZIP dependency for docker images
- Attempting to return geographic areas in OTU smart selector on certain conditions

[#446]: https://github.com/SpeciesFileGroup/taxonworks/issues/446
[#856]: https://github.com/SpeciesFileGroup/taxonworks/issues/856
[#934]: https://github.com/SpeciesFileGroup/taxonworks/issues/934
[#1329]: https://github.com/SpeciesFileGroup/taxonworks/issues/1329
[#1527]: https://github.com/SpeciesFileGroup/taxonworks/issues/1527
[#1552]: https://github.com/SpeciesFileGroup/taxonworks/issues/1552
[#1576]: https://github.com/SpeciesFileGroup/taxonworks/issues/1576
[#1617]: https://github.com/SpeciesFileGroup/taxonworks/issues/1617
[#1618]: https://github.com/SpeciesFileGroup/taxonworks/issues/1618
[#1622]: https://github.com/SpeciesFileGroup/taxonworks/issues/1622
[#1627]: https://github.com/SpeciesFileGroup/taxonworks/issues/1627
[#1628]: https://github.com/SpeciesFileGroup/taxonworks/issues/1628
[#1632]: https://github.com/SpeciesFileGroup/taxonworks/pull/1632
[#1635]: https://github.com/SpeciesFileGroup/taxonworks/issues/1635

## [0.12.12] - 2020-07-22

### Fixed
- Seeing OTUs in Recent that do not belong to project [#1626]

[#1626]: https://github.com/SpeciesFileGroup/taxonworks/issues/1626

## [0.12.11] - 2020-07-14

### Changed
- Type material designations are now grouped by collection object in Browse OTUs (refs [#1614])

### Fixed
- Protonym parent priority soft validation [#1613]
- Type specimens count in Browse OTUs task
- Attempting to update containers as if them were collection objects in Grid Digitizer task [#1601]

[#1601]: https://github.com/SpeciesFileGroup/taxonworks/issues/1601
[#1613]: https://github.com/SpeciesFileGroup/taxonworks/issues/1613
[#1614]: https://github.com/SpeciesFileGroup/taxonworks/issues/1614

## [0.12.10] - 2020-07-07

### Added
- Smart selection source on new combination and citations annotator
- Parsed verbatim label on comprehensive specimen digitization task
- Soft validation in timeline on Browse OTUs [#1593]
- Topic facet in Filter Sources task [#1589]
- Counts on type specimen and specimen records sections on Browse OTUs
- Collecting method parsing in verbatim label text

### Changed
- Replaced vue-resource package by axios
- Disabled parallel upload on new image task [#1596]
- Default verbatim fields order on comprehensive specimen digitization
- Set radius error in verbatim georeference [#1602]
- Timeline filter.
- Missing High classification ranks on classfication autocomplete on new taxon name [#1595]
- Date and geo-coordinates parsing improvements
- Also update cached taxon name fields when Adjective or Participle is selected
- Repositories and Serials smart selectors' recent entries optimizations

### Fixed
- Filter collecting events was passing a wrong (changed name) parameters and structure for maps and geographic area
- Not showing up people list after a crossref source [#1597]
- Scroller in georeferences map modal
- Grid Digitizer task failing to update containerized specimens matched by identifiers [#1601]
- Specimen not associate with genus after create it in type section on new taxon name [#1604]
- Volume field only accepted numbers [#1606]
- Smart selectors not remove the previous selection after press new on New source task [#1605]
- Georeference methods `latitude` returning longitude and `longitude` latitude
- Smart selector overrides custom list after lists are loaded [#1608]
- Duplicate shortcut, using the same one for comprehensive specimen digitization and clipboard [#1612]
- Typo in taxon name relationship soft validation message.

[#1589]: https://github.com/SpeciesFileGroup/taxonworks/issues/1589
[#1593]: https://github.com/SpeciesFileGroup/taxonworks/issues/1593
[#1595]: https://github.com/SpeciesFileGroup/taxonworks/issues/1595
[#1596]: https://github.com/SpeciesFileGroup/taxonworks/issues/1596
[#1597]: https://github.com/SpeciesFileGroup/taxonworks/issues/1597
[#1601]: https://github.com/SpeciesFileGroup/taxonworks/issues/1601
[#1602]: https://github.com/SpeciesFileGroup/taxonworks/issues/1602
[#1604]: https://github.com/SpeciesFileGroup/taxonworks/issues/1604
[#1605]: https://github.com/SpeciesFileGroup/taxonworks/issues/1605
[#1606]: https://github.com/SpeciesFileGroup/taxonworks/issues/1606
[#1608]: https://github.com/SpeciesFileGroup/taxonworks/issues/1608
[#1612]: https://github.com/SpeciesFileGroup/taxonworks/issues/1612

## [0.12.9] - 2020-07-01

### Added
- Endpoint for verbatim label parsing (dates and geographic coordinates)

### Changed
- Display `[sic]` on misspellings of family-group full taxon names

### Fixed
- Containerized objects not showing up together [#1590]
- Citations by Source task not loading taxon names list [#1591]

[#1590]: https://github.com/SpeciesFileGroup/taxonworks/issues/1590
[#1591]: https://github.com/SpeciesFileGroup/taxonworks/issues/1591

## [0.12.8] - 2020-06-29

### Added
- Set autofocus on source and geographic area in OTU radial asserted distribution form
- `/otus/123/coordinate.json` endpoint - all OTUs coordinate with this one (refs [#1585])
- Autosave on new asserted distribution task

### Changed
- Unauthorized json response
- Better error handle for vue-autocomplete
- Replaced old method to handle ajax call in all tasks
- Updated relationships filter param on new taxon name task (refs [#1584])
- ControlledVocabularyTerm model no longer requires SKOS with URI (refs [#1562], [#1561])
- Improved sorting of objects in the Browse Nomenclatue task
- Updated dwc-archive gem to version 1.1.1

### Fixed
- Topic `select_optimized` controller method crash
- Recent list of biological associations not working due to the use of incorrect table

[#1561]: https://github.com/SpeciesFileGroup/taxonworks/issues/1561
[#1562]: https://github.com/SpeciesFileGroup/taxonworks/issues/1562
[#1584]: https://github.com/SpeciesFileGroup/taxonworks/issues/1584
[#1585]: https://github.com/SpeciesFileGroup/taxonworks/issues/1585

## [0.12.7] - 2020-06-26

### Added
- Taxon name status and relationships soft validations display in Browse Nomenclature task
- Interface to select OTUs and create rows in Observation Matrices Dashboard task
- Autosave system in New Taxon Name task (refs [#649])
- Etymology filter in Nomenclature Filter task (refs [#1549])
- Added new shortcuts for Comprehensive Digitization, New Type Specimen, New Taxon Name and Browse Nomenclature tasks
- Classification section in New Taxon Name task
- Spec to test md5 of multi-line verbatim labels  (refs [#1572])
- Display classifications alongside relationships in Browse Nomenclature task
- Add children and add sibling buttons in New Taxon Name task (refs [#1503])
- Link to create new serial on smart selector of New Source tast
- Semantic section coloration in Browse OTU task (refs [#1571])
- Rank prediction in New Taxon Name task (refs [#1054])

### Changed
- Optimized recently used geographic area and sources search
- Improved part of speech and etymology soft validation messages
- Year suffix and pages are now also used when sorting citations in Browse Nomenclature task
- Replaced old geographic area smart selector with newer version
- Swapped 'Masculine' and 'Femenine' positions in New Taxon Name task (refs [#660])
- Replaced uses of `find_each` with `each` (refs [#1548])
- Refactored New Taxon Name front end code
- Display text of some taxon name relationships
- Autocomplete visible in all tabs of smart selector
- OTU autocomplete searches now also matches by common names (refs [#869])
- Browse Taxa task renamed to Browse OTU
- Using unreleased closure_tree code from official repo to address deprecation warning messages
- "valid by default" no longer displayed when a relationship exists in New Taxon Name task (refs [#1525])
- Improvements in BibTex and New Source task UI
- Improvements in role picker and smart selectors in Comprehensive Collection Object Form and New Source tasks
- Optimized some filters for some smart selectors (refs [#1534])
- Smart selector for sources no longer ordered by name
- Some minor UI tweaks in some places
- Updated ruby gems

### Fixed
- Recently used objects code on some models
- Collection Object Filter task not filternig by type material type ([#1551])
- Forms not being cleared when pressing `new` on Compose Biological Relationships task ([#1563])
- Not getting the full list of topics when clicking all in `Radial annotator -> Citation -> Topic` ([#1566])
- Showing name instead of the short name in `Radial Annotator -> Identifiers -> Preview` ([#1567])
- `create` button keeps disabled when creating a new citation fails in `Radial annotator -> Citation` ([#1568])
- Incorrect method call in Match Georeference task view
- Display of misspellings on taxon name relationships
- Femenine and neuter names ending in '-or' not being accepted ([#1575])
- Spinner not disabled when entering malformed URIs in Manage Controlled Vocabulary task form ([#1561])
- "--None--" results obscuring buttons until clicking off the record ([#1558])

[#649]: https://github.com/SpeciesFileGroup/taxonworks/issues/649
[#660]: https://github.com/SpeciesFileGroup/taxonworks/issues/660
[#869]: https://github.com/SpeciesFileGroup/taxonworks/issues/869
[#1054]: https://github.com/SpeciesFileGroup/taxonworks/issues/1054
[#1503]: https://github.com/SpeciesFileGroup/taxonworks/issues/1503
[#1525]: https://github.com/SpeciesFileGroup/taxonworks/issues/1525
[#1534]: https://github.com/SpeciesFileGroup/taxonworks/issues/1534
[#1548]: https://github.com/SpeciesFileGroup/taxonworks/issues/1548
[#1549]: https://github.com/SpeciesFileGroup/taxonworks/issues/1549
[#1551]: https://github.com/SpeciesFileGroup/taxonworks/issues/1551
[#1558]: https://github.com/SpeciesFileGroup/taxonworks/issues/1558
[#1561]: https://github.com/SpeciesFileGroup/taxonworks/issues/1561
[#1563]: https://github.com/SpeciesFileGroup/taxonworks/issues/1563
[#1566]: https://github.com/SpeciesFileGroup/taxonworks/issues/1566
[#1567]: https://github.com/SpeciesFileGroup/taxonworks/issues/1567
[#1568]: https://github.com/SpeciesFileGroup/taxonworks/issues/1568
[#1571]: https://github.com/SpeciesFileGroup/taxonworks/issues/1571
[#1572]: https://github.com/SpeciesFileGroup/taxonworks/issues/1572
[#1575]: https://github.com/SpeciesFileGroup/taxonworks/issues/1575

## [0.12.6] - 2020-06-12
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

[unreleased]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.12.15...development
[0.12.15]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.12.14...v0.12.15
[0.12.14]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.12.13...v0.12.14
[0.12.13]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.12.12...v0.12.13
[0.12.12]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.12.11...v0.12.12
[0.12.11]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.12.10...v0.12.11
[0.12.10]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.12.9...v0.12.10
[0.12.9]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.12.8...v0.12.9
[0.12.8]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.12.7...v0.12.8
[0.12.7]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.12.6...v0.12.7
[0.12.6]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.12.5...v0.12.6
[0.12.5]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.12.4...v0.12.5
[0.12.4]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.12.3...v0.12.4

----
The following versions predate this CHANGELOG. You may check the comparison reports generated by GitHub by clicking the versions below

|<!-- -->|<!-- -->|
|---|---|
|0.12.x|[0.12.3] (2020-06-04) [0.12.2] (2020-06-02) [0.12.1] (2020-05-29) [0.12.0] (2020-05-15)|
|0.11.x|[0.11.0] (2020-04-17)|
|0.10.x|[0.10.9] (2020-04-03) [0.10.8] (2020-03-27) [0.10.7] (2020-03-26) [0.10.6] (2020-03-18) [0.10.5] (2020-03-11) [0.10.4] (2020-03-04) [0.10.3] (2020-02-25) [0.10.2] (2020-02-22) [0.10.1] (2020-02-21) [0.10.0] (2020-02-20)|
|0.9.x|[0.9.8] (2020-02-05) [0.9.7] (2020-02-03) [0.9.6] (2020-01-29) [0.9.5] (2020-01-14) [0.9.4] (2020-01-10) [0.9.3] (2019-12-23) [0.9.2] (2019-12-18) [0.9.1] (2019-12-16) [0.9.0] (2019-12-13)|
|0.8.x|[0.8.9] (2019-12-11) [0.8.8] (2019-12-09) [0.8.7] (2019-12-06) [0.8.6] (2019-12-06) [0.8.5] (2019-11-27) [0.8.4] (2019-11-26) [0.8.3] (2019-11-22) [0.8.2] (2019-11-21) [0.8.1] (2019-11-19) [0.8.0] (2019-11-16)|
|0.7.x|[0.7.4] (2019-10-23) [0.7.3] (2019-10-19) [0.7.2] (2019-10-05) [0.7.1] (2019-10-02) [0.7.0] (2019-09-30)|
|0.6.x|[0.6.1] (2019-06-16) [0.6.0] (2019-06-14)|
|0.5.x|[0.5.4] (2019-05-02) [0.5.3] (2019-05-02) [0.5.2] (2019-04-23) [0.5.1] (2019-04-18) [0.5.0] (2019-04-10)|
|0.4.x|[0.4.5] (2018-12-14) [0.4.4] (2018-12-06) [0.4.3] (2018-12-04) [0.4.2] (2018-12-04) [0.4.1] (2018-11-28) [0.4.0] (2018-11-08)|
|0.3.x (\*)|[0.3.16] (2018-09-24) [0.3.15] (2018-09-17) [0.3.14] (2018-09-11) [0.3.13] (2018-09-11) [0.3.12] (2018-05-14) [0.3.11] (2018-05-11) [0.3.9] (2018-05-11) [0.3.7] (2018-05-10) [0.3.6] (2018-05-10) [0.3.4] (2018-05-02) [0.3.3] (2018-05-02) [0.3.2] (2018-03-27) [0.3.1] (2018-03-08) [0.3.0] (2018-03-08)|
|0.2.x (\*)|[0.2.29] (2018-02-05) [0.2.28] (2017-07-19) [0.2.27] (2017-07-19) [0.2.26] (2017-07-16) [0.2.25] (2017-07-12) [0.2.24] (2017-07-12) [0.2.23] (2017-07-11) [0.2.22] (2017-07-11) [0.2.21] (2017-07-10) [0.2.20] (2017-07-10) [0.2.19] (2017-07-10) [0.2.18] (2017-07-10) [0.2.17] (2017-07-10) [0.2.15] (2017-07-10) [0.2.11] (2017-07-10) [0.2.10] (2017-07-10) [0.2.9] (2017-07-10) [0.2.8] (2017-07-10) [0.2.6] (2017-07-10) [0.2.5] (2017-07-10) [0.2.4] (2017-07-10) [0.2.3] (2017-07-10) [0.2.2] (2017-07-10) [0.2.1] (2017-07-10) [0.2.0] (2017-07-10)|
|0.1.x|*Unreleased*|
|0.0.x|[0.0.10] (2017-06-23) [0.0.9] (2017-06-23) [0.0.8] (2017-06-09) [0.0.6] (2017-06-09) [0.0.5] (2017-06-09) [0.0.4] (2017-06-09) [0.0.3] (2017-06-02) [0.0.2] (2017-06-01) 0.0.1(\*\*) (2017-06-01)|

*(\*) Missing versions have not been released.*

*(\*\*) Report cannot be provided as this is the first release.*

[0.12.3]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.12.2...v0.12.3
[0.12.2]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.12.1...v0.12.2
[0.12.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.12.0...v0.12.1
[0.12.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.11.0...v0.12.0


[0.11.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.10.9...v0.11.0

[0.10.9]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.10.8...v0.10.9
[0.10.8]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.10.7...v0.10.8
[0.10.7]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.10.6...v0.10.7
[0.10.6]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.10.5...v0.10.6
[0.10.5]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.10.4...v0.10.5
[0.10.4]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.10.3...v0.10.4
[0.10.3]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.10.2...v0.10.3
[0.10.2]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.10.1...v0.10.2
[0.10.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.10.0...v0.10.1
[0.10.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.9.8...v0.10.0

[0.9.8]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.9.7...v0.9.8
[0.9.7]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.9.6...v0.9.7
[0.9.6]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.9.5...v0.9.6
[0.9.5]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.9.4...v0.9.5
[0.9.4]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.9.3...v0.9.4
[0.9.3]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.9.2...v0.9.3
[0.9.2]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.9.1...v0.9.2
[0.9.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.9.0...v0.9.1
[0.9.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.8.8...v0.9.0

[0.8.9]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.8.8...v0.8.9
[0.8.8]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.8.7...v0.8.8
[0.8.7]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.8.6...v0.8.7
[0.8.6]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.8.5...v0.8.6
[0.8.5]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.8.4...v0.8.5
[0.8.4]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.8.3...v0.8.4
[0.8.3]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.8.2...v0.8.3
[0.8.2]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.8.1...v0.8.2
[0.8.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.8.0...v0.8.1
[0.8.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.7.3...v0.8.0

[0.7.4]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.7.3...v0.7.4
[0.7.3]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.7.2...v0.7.3
[0.7.2]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.7.1...v0.7.2
[0.7.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.7.0...v0.7.1
[0.7.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.6.1...v0.7.0

[0.6.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.6.0...v0.6.1
[0.6.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.5.4...v0.6.0

[0.5.4]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.5.3...v0.5.4
[0.5.3]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.5.2...v0.5.3
[0.5.2]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.5.1...v0.5.2
[0.5.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.4.5...v0.5.0

[0.4.5]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.4.4...v0.4.5
[0.4.4]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.4.3...v0.4.4
[0.4.3]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.4.2...v0.4.3
[0.4.2]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.4.1...v0.4.2
[0.4.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.3.16...v0.4.0

[0.3.16]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.3.15...v0.3.16
[0.3.15]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.3.14...v0.3.15
[0.3.14]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.3.13...v0.3.14
[0.3.13]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.3.12...v0.3.13
[0.3.12]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.3.11...v0.3.12
[0.3.11]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.3.9...v0.3.11
[0.3.9]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.3.7...v0.3.9
[0.3.7]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.3.6...v0.3.7
[0.3.6]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.3.4...v0.3.6
[0.3.4]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.3.3...v0.3.4
[0.3.3]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.3.2...v0.3.3
[0.3.2]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.2.29...v0.3.0

[0.2.29]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.2.28...v0.2.29
[0.2.28]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.2.27...v0.2.28
[0.2.27]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.2.26...v0.2.27
[0.2.26]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.2.25...v0.2.26
[0.2.25]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.2.24...v0.2.25
[0.2.24]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.2.23...v0.2.24
[0.2.23]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.2.22...v0.2.23
[0.2.22]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.2.21...v0.2.22
[0.2.21]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.2.20...v0.2.21
[0.2.20]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.2.19...v0.2.20
[0.2.19]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.2.18...v0.2.19
[0.2.18]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.2.17...v0.2.18
[0.2.17]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.2.15...v0.2.17
[0.2.15]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.2.11...v0.2.15
[0.2.11]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.2.10...v0.2.11
[0.2.10]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.2.9...v0.2.10
[0.2.9]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.2.8...v0.2.9
[0.2.8]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.2.6...v0.2.8
[0.2.6]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.2.5...v0.2.6
[0.2.5]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.2.4...v0.2.5
[0.2.4]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.2.3...v0.2.4
[0.2.3]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.2.2...v0.2.3
[0.2.2]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.0.10...v0.2.0

[0.0.10]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.0.9...v0.0.10
[0.0.9]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.0.8...v0.0.9
[0.0.8]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.0.7...v0.0.8
[0.0.7]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.0.6...v0.0.7
[0.0.6]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.0.5...v0.0.6
[0.0.5]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.0.4...v0.0.5
[0.0.4]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.0.3...v0.0.4
[0.0.3]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.0.1...v0.0.2
