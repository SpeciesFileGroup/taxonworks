# Changelog

All (hopefully) notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
This project <em>does not yet</em> adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) as the API is evolving and MINOR patches may be backwards incompatible.

## [unreleased]

### Added
- Determination, OTU and repository smart selectors on New image task [#2101]

### Fixed

- Not being able to get pinboard items on some circumstances

[#2101]: https://github.com/SpeciesFileGroup/taxonworks/issues/2101

## [0.16.4] - 2020-03-09

### Added
- Multiple presnece/absence params for collection objects filter [#2080] 
- Buffered field facets for collection object [#1456], [#1835]
- Filter collection objects by determiner (Person) [#1835]
- Tag smart selector on create collection object in New collecting event task [#2066]
- Year field on person source in new source task
- Create new biocuration and in relationship links in filter collection object
- Determiner in filter collection object
- HEIC image format support
- PDF drop box on new source task [#2094]
- Confirmation modal to clone source [#2099]
- Smart selector on attributions in Radial annotator [#2081]

### Fixed
- Uniquifying 2 people attached to the same source raises [#2078]
- Render Source::Human cached with year, udpate `citation_tag` [#2067] 
- Qualitative states in matrix row coder order correctly [#2076]
- Better source cached filter wildcards [#1557]
- Observation matrices hub link [#2071]
- Refresh button component [#2085]
- Update comprehensive url [#2096]
- `/units.json` called 2x [#2089]
- Edit `error radius` of a georeference in new collecting event task [#2087]
- Previous and next navigate navigation links [#2039]

### Changed
- Now using ImageMagick 7 instead of 6
- Production and development docker images are now based off a single base image
- Development docker environment uses rvm instead of rbenv (matching version manager that has been used for production)
- Updated npm packages

[#2039]: https://github.com/SpeciesFileGroup/taxonworks/issues/2039
[#2078]: https://github.com/SpeciesFileGroup/taxonworks/issues/2078
[#2067]: https://github.com/SpeciesFileGroup/taxonworks/issues/2067
[#2076]: https://github.com/SpeciesFileGroup/taxonworks/issues/2076
[#1557]: https://github.com/SpeciesFileGroup/taxonworks/issues/1557
[#1835]: https://github.com/SpeciesFileGroup/taxonworks/issues/1835
[#1456]: https://github.com/SpeciesFileGroup/taxonworks/issues/1456
[#2080]: https://github.com/SpeciesFileGroup/taxonworks/issues/2080
[#2066]: https://github.com/SpeciesFileGroup/taxonworks/issues/2066
[#2071]: https://github.com/SpeciesFileGroup/taxonworks/issues/2071
[#2081]: https://github.com/SpeciesFileGroup/taxonworks/issues/2081
[#2085]: https://github.com/SpeciesFileGroup/taxonworks/issues/2085
[#2087]: https://github.com/SpeciesFileGroup/taxonworks/issues/2087
[#2089]: https://github.com/SpeciesFileGroup/taxonworks/issues/2089
[#2094]: https://github.com/SpeciesFileGroup/taxonworks/issues/2094
[#2096]: https://github.com/SpeciesFileGroup/taxonworks/issues/2096
[#2099]: https://github.com/SpeciesFileGroup/taxonworks/issues/2099

## [0.16.3] - 2021-02-26
### Added
- Additional date recognition format in date RegEx
- Pagination on Browse Annotations [#1438]
- New combination for subgenus [#748]
- Warn about unsaved changes on Accession metadata [#1858]

### Fixed
- `eventDate`/`eventTime` output format not being ISO8601-compliant [#1939]
- Some value label in Filter sources
- Dropzone error message
- Redirect to Image Matrix on OTU Radial [#2033]
- Race condition problem when generating dwc_occurrences indexing

### Changed
- Pagination in Filter sources
- Replaced geckodriver-helper with webdrivers gem
- Improvement sort table on collection object, source and nomenclature filters

[#748]: https://github.com/SpeciesFileGroup/taxonworks/issues/748
[#1438]: https://github.com/SpeciesFileGroup/taxonworks/issues/1438
[#1858]: https://github.com/SpeciesFileGroup/taxonworks/issues/1858
[#1939]: https://github.com/SpeciesFileGroup/taxonworks/issues/1939
[#2033]: https://github.com/SpeciesFileGroup/taxonworks/issues/2033

## [0.16.2] - 2021-02-18

### Added
- Additional date recognition format in date RegEx
- Fields with/out some value facet for Source filter [#2023]
- Keyword params to TaxonName API
- Adds database index to Sour title, year, author
- Keyword and/or logic in Tag facets (throughout) [#2026], [#2032]
- `/ap1/v1/stats` endpoint [#1871]
- `papertrail.json?object_global_id=`
- Quick label on collection object quick form [#2003]
- Lock biological relationship in radial object [#2036]
- Confirmation popup to delete a type material in comprehensive
- Tag facet to filter nomenclature [#2047]

### Changed
- Checkmark on verbatim should visible only
- Updated gems (`bundle update` without altering `Gemfile`)
- Updated node packages (`npm update` without altering `packages.json`)
- Changed `verbatim author` for `cached_author_year` in filter nomenclature
- Keywords styled after choice in Tag facet
- Keywords removed from all list after choice in Tag facet

### Fix
- Model LoanItem - Tagged batch adds tag, not object [#2051]
- Prevent non-loanable things being loaned [#2043]
- `ancestors` param properly permitted TaxonName api/filter
- TaxonName#name allowed spaces [#2009]
- Fix help tip of pinboard navigator shortcut
- Generate label button [#2002]
- Save collectors in new collecting event task [#2016]
- Fix image viewer on filter image task
- Image caption modal size [#2030]
- Set created loan object [#2042]
- Refactor edit load items [#2044]

[#2032]: https://github.com/SpeciesFileGroup/taxonworks/issues/2032
[#2051]: https://github.com/SpeciesFileGroup/taxonworks/issues/2051
[#2043]: https://github.com/SpeciesFileGroup/taxonworks/issues/2043
[#2026]: https://github.com/SpeciesFileGroup/taxonworks/issues/2026
[#2023]: https://github.com/SpeciesFileGroup/taxonworks/issues/2023
[#2009]: https://github.com/SpeciesFileGroup/taxonworks/issues/2009
[#1871]: https://github.com/SpeciesFileGroup/taxonworks/issues/1871
[#2002]: https://github.com/SpeciesFileGroup/taxonworks/issues/2002
[#2003]: https://github.com/SpeciesFileGroup/taxonworks/issues/2003
[#2012]: https://github.com/SpeciesFileGroup/taxonworks/issues/2012
[#2016]: https://github.com/SpeciesFileGroup/taxonworks/issues/2016
[#2030]: https://github.com/SpeciesFileGroup/taxonworks/issues/2030
[#2042]: https://github.com/SpeciesFileGroup/taxonworks/issues/2042
[#2044]: https://github.com/SpeciesFileGroup/taxonworks/issues/2044
[#2045]: https://github.com/SpeciesFileGroup/taxonworks/issues/2045
[#2047]: https://github.com/SpeciesFileGroup/taxonworks/issues/2047

## [0.16.1] - 2021-01-26

### Fixed
- Missing `depiction_object_type` on New image task [#1995]
- Sort case-insensitive [#1985]

[#1985]: https://github.com/SpeciesFileGroup/taxonworks/issues/1985
[#1995]: https://github.com/SpeciesFileGroup/taxonworks/issues/1995

## [0.16.0] - 2021-01-25
### Added
- New collecting event task [#1530]
- "Quick" collection objects options from new collecting event task
- New WKT georeference inputs
- Auto-georeference and date Collecting Events by depicting images with pertinent EXIF data
- Route linting specs
- Generate label (alpha), pastes values into print label input 
- Collecting event navigation options (next/previous with/out <many things>
- Nested_attributes for Labels
- Collection object/and collecting event navigation options/bridges
- `/collecting_events/preview?<filter_params>` a preview look for brief tables
- Subclasses for labels:`Label::QrCode`, `Label::Code128`
- Include `rqrcode`, `barby` for barcode rendering
- Add `label` attribute to Label JSON response that renders QR code
- Add accommodation for printing pages of barcode-based labels
- Add `Georeference::Wkt` an anonymous WKT based georeference assertion
- Add option to disable name-casing when Person is created from `/people/new` [#1967] 
- Full CASTOR (taxon names batch load) example template, CASTOR preview notices
- New ICZN class added: NoDiagnosisAfter1930AndRejectedBefore2000 for family-group names
- Add image attributions, original citation and editor options in image viewer [#1978]
- Browse current OTU button in Browse OTU

### Changed
- Moved buttons in collecting event on comprehensive task [#1986]
- Improved collecting event status in smart selector on comprehensive digitization
- Some tasks route names were "malformed" and renamed
- ENV variable`TAXONWORKS_TEST_LINTING=true` must now be `true`, not anything, to trigger linting specs
- Setting `Identifier#cached` uses a build getter to enable Label building
- Georeference validation requires CollectingEvent (enabled by proper use of `:inverse_of`)
- Tweak to how `pinned?` is calculated trying to eliminate database calls
- Minor cleanup of batch preview layouts
- Changed softvalidation message for names being on Official ICZN lists
- Fetch codecov, seedback and closure_tree gems from RubyGems.
- Updated gems (`bundle update` without altering `Gemfile`).
- Remove `no_leaves`= true from taxon name on filter images task [#1953]
- Turn off autocomplete feature on vue autocomplete [#1956]
- Limited CoLDP exports runtime to 1 hour and 2 attemps.
- Turn off autocomplete on new taxon name task
- Replaced display name attribute for object_label in parent autocomplete on New taxon name task
- Filter task by name only [#1962]
- Search geographic area by verbatim coordinates on new collecting event
- Show coordinates from verbatim georeference
- Parsed verbatim label to fields
- Parsed EXIF coordinates to verbatim fields
- Changed autocomplete label [#1988]
- Using newer biodiversity gem from official source
- Updated gems (`bundle update` without altering `Gemfile`)

### Fixed
- CoLDP [sic], errant chresonym, and basionym ids for misspellings
- Loan items reference proper housekeeping in table
- Line links of batch-preview results
- broken API download link for exported references [#1908]
- removed BASIS task stub [#1716]
- `/api/v1/notes` project scoping [#1958]
- `is_community?` reporting `false` for some models without `project_id`
- New source after cloning not display changes on authors / editors lists
- Edit taxon name firing multiple updates when updating gender [#1970]
- Correct image size on image viewer
- Save pages before clone person on new taxon name [#1977]
- Correct count display of attributions [#1979]
- Uncheck collecting event option [#1980]
- Trip Code/Identifier not visible in header of Edit collecting event [#1990]

[#1530]: https://github.com/SpeciesFileGroup/taxonworks/issues/1530
[#1716]: https://github.com/SpeciesFileGroup/taxonworks/issues/1716
[#1908]: https://github.com/SpeciesFileGroup/taxonworks/issues/1908
[#1949]: https://github.com/SpeciesFileGroup/taxonworks/issues/1949
[#1953]: https://github.com/SpeciesFileGroup/taxonworks/issues/1953
[#1956]: https://github.com/SpeciesFileGroup/taxonworks/issues/1956
[#1958]: https://github.com/SpeciesFileGroup/taxonworks/issues/1958
[#1963]: https://github.com/SpeciesFileGroup/taxonworks/issues/1963
[#1967]: https://github.com/SpeciesFileGroup/taxonworks/issues/1967
[#1970]: https://github.com/SpeciesFileGroup/taxonworks/issues/1970
[#1977]: https://github.com/SpeciesFileGroup/taxonworks/issues/1977
[#1978]: https://github.com/SpeciesFileGroup/taxonworks/issues/1978
[#1979]: https://github.com/SpeciesFileGroup/taxonworks/issues/1979
[#1980]: https://github.com/SpeciesFileGroup/taxonworks/issues/1980
[#1986]: https://github.com/SpeciesFileGroup/taxonworks/issues/1986
[#1988]: https://github.com/SpeciesFileGroup/taxonworks/issues/1988
[#1990]: https://github.com/SpeciesFileGroup/taxonworks/issues/1990

## [0.15.1] - 2020-12-14
### Added
- `Person` can not be active for > 119 years
- Show buffered values in `Task - Browse collection objects` [#1931]
- Default pin button on Uniquify people task
- Checkbox to Select/unselect all match people on Uniquify people task [#1921]
- Pixels to centimeter on new image task

### Changed
- Clean timeline display in `Task - Browse collection objects`
- `db:seed` displays password for created users and adds admin to Default project [#1913]
- Start date needs to be set before set end date on Housekeeping facet
- Bump node package `ini` from 1.3.5 to 1.3.7

### Fixed
- CVT smart selectors/pinboard scope broken [#1940] [#1941]
- Image filter `ancestor_id` was to be `taxon_name_id` or `taxon_name_id[]` [#1916]
- Bad Image select_option sort [#1930] 
- Housekeeping filter params now less restrictive [#1920] PENDING UI TEST 
- ShallowPolymorphic called in `.json` form [#1928]
- Documentation of param names, examples, for the "CASTOR" taxon name batch load [#1926]
- `tw:db:load` task not handling settings reliably. [#1914]
- Set `pulse` attribute true on radial annotator for object with annotations on data views and Browse nomenclature task
- Invalid attribute `:note` in Note API result view.
- Malformed PDF exception handling in Document model.
- Clipboard copy shortcut
- Source hub link on Citations by source task
- Clean content editor after change a topic


[#1941]: https://github.com/SpeciesFileGroup/taxonworks/issues/1941
[#1940]: https://github.com/SpeciesFileGroup/taxonworks/issues/1940
[#1916]: https://github.com/SpeciesFileGroup/taxonworks/issues/1916
[#1931]: https://github.com/SpeciesFileGroup/taxonworks/issues/1931
[#1930]: https://github.com/SpeciesFileGroup/taxonworks/issues/1930
[#1920]: https://github.com/SpeciesFileGroup/taxonworks/issues/1920
[#1928]: https://github.com/SpeciesFileGroup/taxonworks/issues/1928
[#1926]: https://github.com/SpeciesFileGroup/taxonworks/issues/1926
[#1913]: https://github.com/SpeciesFileGroup/taxonworks/issues/1913
[#1914]: https://github.com/SpeciesFileGroup/taxonworks/issues/1914
[#1921]: https://github.com/SpeciesFileGroup/taxonworks/issues/1921

## [0.15.0] - 2020-11-30

### Added
- Export project database task [#1868]
- Additional collecting methods recognized from the collecting event label
- Added content filter, API endpoints [#1905] 
- New greatly simplified controller concern `ShallowPolymorphic` for handling link b/w shallow routes and filters
- Note filter improvements, specs, new params, API exposure [#XXX]
- `person#sources` `has_many` (very slight potential for issues)
- Multiple new people filter params, see `lib/queries/person/filter.rb` [#1859]
- People can be Tagged
- Added image filter [#1454]
- Added image smart selector [#1832]
- Added `pixels_to_centimeter` to images [#1785]
- PENDING TEST - API - `sort` (with `classification`, `alphabetical` options) to `/taxon_names` [#1865]
- Taxon determination, citations and collecting event information in specimen record on browse OTU
- Serial facet on filter sources
- Pulse animation for radial annotator [#1822]
- OTU column in asserted distribution on Browse OTU [#1846]
- Radial annotator on Uniquify people task
- History title on Browse nomenclature
- otu_ids param on Image matrix task
- Open image matrix button on Interactive keys task
- Citations on image response
- View mode on image matrix
- Lock view option for smart selector
- Sortable option to lock column/rows on edit/new observation matrix task [#1895]
- Media Descriptor support on Matrix Row Coder [#1896]
- Free Text Descriptor support on Matrix Row Coder [#1896]
- Search source on New source task [#1899]
- Link to Browse OTU on New asserted distribution task [#1893]
- Link to Browse OTU on comprehensive specimen digitization [#1889]

### Fixed
- Potential issue (may be others) with CoLDP raising in the midst of large exports
- People filter role + name [#1662] 
- Fix family synonym validation [#1892]
- Fix matrix view row order [#1881]
- CVT view helper bug with predicates
- Fixed database seeding bugs.
- Fixed display problem of OTUs without taxon name on Browse OTU
- Edit asserted distribution on quick forms
- Reference overflow on Browse nomenclature
- Date requested filled automatically [#1872]
- Remove collecting event on comprehensive specimen digitization [#1878]
- Loan smart selector DB query.
- Label overlap on menu on observation matrices view [#1894]
- Remove repository on comprehensive specimen digitization [#1897]

### Changed
- change the order of TaxonName softvalidation to bring the duplicate message on the top
- tweaked CoLDP `reified` id concept and use
- removed `most_recent_upates` from Content params
- removed `/contents/filter.json` endpoint, use `/contents.json`
- Deprecating `Concerns::Polymorphic` for `ShallowPolymorphic`, in progress, see Notes controller
- Note filter params `query_string` => `text`, `note_object_types[]` => `note_object_type[]`, `note_object_ids[]` => `note_object_id[]`, added corresponding non-array versions
- Moved `levenshtein_distance` to Query for general use
- Remove `people/123/similar` endpoint (used `/index`)
- Person filter `person_wildcards` is `person_wildcard`
- Person filter behaviour vs. `levenshtein_cuttof`
- cached_valid_taxon_name_id updated for combination after valid status is assigned.
- updated soft validation for 'Uncertain placement'
- [sic] changed to (sic) for misspelled bacterial names
- Additional date and geographical coordinate formats added to the Verbatim label RegEx parsers 
- Observation matrix could be resolved without observation_matrix_id, only with otu_filter
- Running `rake db:seed` without `user_id`/`project_id` is now possible.
- Disabled hamburger menu when no functionality behind it on Browse OTU [#1737]
- No longer needed set user on User facet in filters
- Autocomplete label for original combination on New taxon name task
- Changed "n/a" to combination label on Browse nomenclature
- Create original citation in image matrix task
- Autocomplete list style
- Edit button color on type material species task [#1898]
- GitHub Actions used as main CI/CD provider
- Updated vulnerable node packages [#1912]

[#1905]: https://github.com/SpeciesFileGroup/taxonworks/issues/1905
[#1662]: https://github.com/SpeciesFileGroup/taxonworks/issues/1662
[#1859]: https://github.com/SpeciesFileGroup/taxonworks/issues/1859
[#1881]: https://github.com/SpeciesFileGroup/taxonworks/issues/1881
[#1454]: https://github.com/SpeciesFileGroup/taxonworks/issues/1454
[#1832]: https://github.com/SpeciesFileGroup/taxonworks/issues/1832
[#1785]: https://github.com/SpeciesFileGroup/taxonworks/issues/1785
[#1737]: https://github.com/SpeciesFileGroup/taxonworks/issues/1737
[#1865]: https://github.com/SpeciesFileGroup/taxonworks/issues/1865
[#1822]: https://github.com/SpeciesFileGroup/taxonworks/issues/1822
[#1846]: https://github.com/SpeciesFileGroup/taxonworks/issues/1846
[#1868]: https://github.com/SpeciesFileGroup/taxonworks/issues/1868
[#1872]: https://github.com/SpeciesFileGroup/taxonworks/issues/1872
[#1889]: https://github.com/SpeciesFileGroup/taxonworks/issues/1889
[#1893]: https://github.com/SpeciesFileGroup/taxonworks/issues/1893
[#1894]: https://github.com/SpeciesFileGroup/taxonworks/issues/1894
[#1895]: https://github.com/SpeciesFileGroup/taxonworks/issues/1895
[#1896]: https://github.com/SpeciesFileGroup/taxonworks/issues/1896
[#1897]: https://github.com/SpeciesFileGroup/taxonworks/issues/1897
[#1898]: https://github.com/SpeciesFileGroup/taxonworks/issues/1898
[#1899]: https://github.com/SpeciesFileGroup/taxonworks/issues/1899
[#1912]: https://github.com/SpeciesFileGroup/taxonworks/pull/1912

## [0.14.1] - 2020-10-22

### Added
- API - `type` to /roles/:id
- API - `year` to /taxon_names
- API - `include_roles` param to /people
- API - `taxon_name_author_ids[]=`, `taxon_name_author_ids_or` params to /taxon_names
- API - `collector_ids[]=`, `collector_ids_or` params to /collecting_events
- Shape on asserted distribution list [#1828]
- Row filter on Interactive keys task
- Interactive keys and image matrix buttons on observation matrix dashboard

### Fixed
- Wrong param attribute in topic smart selector on radial annotator [#1829]
- Show repository on Browse OTU
- Enable search after fill collecting event fields [#1833]
- Missing geo_json param on geographic_area request [#1840]

### Changed
- Exclude Roles from response from /api/v1/people by default
- Increased `max_per_page` to 10000
- Random words clashes mitigation: Project factory names made longer and `Faker` unique generator is reset only between specs instead of before each test.
- Removed pages field on topic section
- Improved verbatim date parsing
- Georeference scope over geographic area scope [#1841]

[#1454]: https://github.com/SpeciesFileGroup/taxonworks/issues/1454
[#1832]: https://github.com/SpeciesFileGroup/taxonworks/issues/1832
[#1785]: https://github.com/SpeciesFileGroup/taxonworks/issues/1785
[#1828]: https://github.com/SpeciesFileGroup/taxonworks/issues/1828
[#1829]: https://github.com/SpeciesFileGroup/taxonworks/issues/1829
[#1833]: https://github.com/SpeciesFileGroup/taxonworks/issues/1833
[#1840]: https://github.com/SpeciesFileGroup/taxonworks/issues/1840
[#1841]: https://github.com/SpeciesFileGroup/taxonworks/issues/1841
[#1878]: https://github.com/SpeciesFileGroup/taxonworks/issues/1878

## [0.14.0] - 2020-10-16

### Added
- Added additional date recognition format for RegEx
- Added OTU filter in the interactive key API
- Collecting Event API endpoints
- Collection Object API endpoints
- Biological Assertion API endpoints
- Asserted Distribution API endpoints
- New Otu API params
- People filter API endpoints [#1509]
- Identifier filter API endpoints [#1510]
- Source filter API endpoints [#1511]
- New Interactive Key task [#1810] 
- New model for matrix based interactive keys which produce JSON for the Interactive Key task [#1810]
- `weight` field to descriptor
- Ancestors facet on filter nomenclature [#1791]
- TW_DISABLE_DB_BACKUP_AT_DEPLOY_TIME env var to disable built-in backup functionality at deploy/database-update time.
- Display coordinate type specimens [#1811]
- Changed background color header for invalid names on Browse OTU
- Taxonworks version in header bar when not running in sandbox mode

### Fixed
- Fixed radial navigator broken for some data [#1824]
- Fixed IsData position [#1805]
- Collecting event object radial metadata settings
- Webpack resolved_paths deprecation warning
- Missing /otus/:otu_id/taxon_determinations route
- tw:db:restore task not picking up database host settings
- Create citation on new combination without pages
- Param descriptor id on new descriptor task [#1798]
- Filter by user on filter nomenclature [#1780]
- Optimized selector queries for Loan model

### Changed
- Fix original author string for Plant names
- Additional date format added for date recognition RegEx
- Removed some attributes from api/v1 endpoints to simplify responses
- type_materials/:id.json includes `original_combination` string
- CoLDP references are full cached values, not partially passed
- Combination nomenclatural code inference drawn from members, not parent
- Some nomenclature rank related simbols moved to constants
- Load Images for coordinate OTUs [#1787]
- Extended New Image task upload timeout from 30 seconds to 10 minutes
- Updated rgeo-proj4 gem


[#1824]: https://github.com/SpeciesFileGroup/taxonworks/issues/1824
[#1805]: https://github.com/SpeciesFileGroup/taxonworks/issues/1805
[#1509]: https://github.com/SpeciesFileGroup/taxonworks/issues/1509
[#1510]: https://github.com/SpeciesFileGroup/taxonworks/issues/1510
[#1511]: https://github.com/SpeciesFileGroup/taxonworks/issues/1511
[#1780]: https://github.com/SpeciesFileGroup/taxonworks/issues/1780
[#1791]: https://github.com/SpeciesFileGroup/taxonworks/issues/1791 
[#1787]: https://github.com/SpeciesFileGroup/taxonworks/issues/1787
[#1798]: https://github.com/SpeciesFileGroup/taxonworks/issues/1798
[#1810]: https://github.com/SpeciesFileGroup/taxonworks/pull/1810
[#1811]: https://github.com/SpeciesFileGroup/taxonworks/issues/1811

## [0.13.0] - 2020-09-22

### Changed
- Removed forced dependency on google-protobuf gem
- Updated gems
- Browse OTU page unifies coordinate OTUs for Asserted Distribution and Biological Associations [#1570]
- Handling for new unicode minutes, seconds symbols [#1526]
- Descriptor object radial paths
- Many specs related to dynamic observation matrix items
- Improvements to Descriptor autocomplete labels [#1727]
- Added `rake tw:maintenance:otus:missplaced_references` [#1439]
- Pdf viewer button on Documentation and Source views [#1693]
- Spinner for when converting verbatim to bibtex [#1710]
- Set OTU in determination when otu_id param is present on comprehensive task
- "Create georeference from verbatim" button in Parsed column on comprehensive task
- Sortable order for Type material, Biological association and Determinations on comprehensive task
- User facet on Filter nomenclature task [#1720]
- Pagination on Filter noemnclature task [#1724]
- Biological associations filter on Browse OTU

### Changed
- AssertedDistribution filter `otu_id` and `geographic_area_id` can now also take array form, e.g. `otu_id[]=`
- Preload all CSL styles via fixed constant, increasing boot speed [#1749]
- Return value format for Utilities::Geo.distance_in_meters changed from \[Float\] to \[String\]
- Data migration updating all `type` column values for matrix row/column items
- Tweaked JSON attribute response for matrix rows and columns very slightly
- Updated observation item types to properly nest them, inc. all downstream changes (Factories, etc.)
- Unfied matrix hooks in various places
- Updated some matrix related routes to point to tasks 
- Updated respec `matrix` tag to `observation_matrix`
- Methods that write to cached should not fire callbacks, potential for [#1701]
- Using custom geckodriver-helper for Firefox 80 support
- Override browser shortcuts on task hotkeys [#1738]
- Biological associations section on Browse OTU
- TW now supports Postgres 12 [#1305]
- Replaced biodiversity with custom gem repo using IPC with gnparser processes
- Updated gems
- Character "΄" also accepted as minute specifier in coordinates parsing.

## Fixed
- Fixed LOW_PROBABILITY constant message
- Matrix rows/items prevent OTU (and collection object) from being destroyed [#1159]
- Scope of dynamic taxon name row item [#1747]
- Processing of values (in distance_in_meters) to limit significant digits of results of unit conversions. Decimal degrees not affected at this time. [#1512]
- Character state order not correct in Nexus format [#1574]
- Not able to destroy matrix rows or matrices [#1520], [#1123]
- Dynamic observeratoin matrix items not properly scoped/behaving [#1125]
- Destroy pdf pages before create new ones [#1680]
- Serial multiple updates did not update bibtex author field [#1709]
- Fix (likely) for pinboard items failing to remove [#1690]
- Better response for failed collecting event cloning [#1705]
- Cleaned up deprecated biological associations graph autcomplete [#1707]
- Colliding `namespace` method for identifiers breaks identifiers list [#1702]
- Graceful failed serial destroy response [#1703]
- Restored Show -> edit link [#1699]
- Enable search button after pick a collecting event date on Filter collection objects task [#1728]
- Misppeling collecting_event_ids parameter [#1729]
- Non-original combination authorship lacking parentheses [#1686]

[#1570]: https://github.com/SpeciesFileGroup/taxonworks/issues/1570
[#1749]: https://github.com/SpeciesFileGroup/taxonworks/issues/1749
[#1159]: https://github.com/SpeciesFileGroup/taxonworks/issues/1159
[#1747]: https://github.com/SpeciesFileGroup/taxonworks/issues/1747
[#1512]: https://github.com/SpeciesFileGroup/taxonworks/issues/1512
[#1526]: https://github.com/SpeciesFileGroup/taxonworks/issues/1526
[#1727]: https://github.com/SpeciesFileGroup/taxonworks/issues/1727
[#1574]: https://github.com/SpeciesFileGroup/taxonworks/issues/1574
[#1520]: https://github.com/SpeciesFileGroup/taxonworks/issues/1520
[#1123]: https://github.com/SpeciesFileGroup/taxonworks/issues/1123
[#1125]: https://github.com/SpeciesFileGroup/taxonworks/issues/1125
[#1439]: https://github.com/SpeciesFileGroup/taxonworks/issues/1439
[#1709]: https://github.com/SpeciesFileGroup/taxonworks/issues/1709
[#1680]: https://github.com/SpeciesFileGroup/taxonworks/issues/1680
[#1690]: https://github.com/SpeciesFileGroup/taxonworks/issues/1690
[#1693]: https://github.com/SpeciesFileGroup/taxonworks/issues/1693
[#1699]: https://github.com/SpeciesFileGroup/taxonworks/issues/1699
[#1701]: https://github.com/SpeciesFileGroup/taxonworks/issues/1701
[#1705]: https://github.com/SpeciesFileGroup/taxonworks/issues/1705
[#1707]: https://github.com/SpeciesFileGroup/taxonworks/issues/1707
[#1702]: https://github.com/SpeciesFileGroup/taxonworks/issues/1702
[#1703]: https://github.com/SpeciesFileGroup/taxonworks/issues/1703
[#1710]: https://github.com/SpeciesFileGroup/taxonworks/issues/1710
[#1720]: https://github.com/SpeciesFileGroup/taxonworks/issues/1720
[#1724]: https://github.com/SpeciesFileGroup/taxonworks/issues/1724
[#1738]: https://github.com/SpeciesFileGroup/taxonworks/issues/1738
[#1686]: https://github.com/SpeciesFileGroup/taxonworks/issues/1686
[#1305]: https://github.com/SpeciesFileGroup/taxonworks/pull/1305

## [0.12.17] - 2020-02-02

### Added
- Successfull source destroy message 
- Pending - Definition field to BiologicalRelationship model and views [#1672]
- New button to (attempt to) convert verbatim sources to Bibtex via Crossref
- Model methods and attribute to change Source Verbatim to Bibtex [#1673]
- DOMPurify package to sanitize html
- List all Keyword and Topics in smart selector on filter source [#1675]
- Added data links tool in markdown editor (Ctrl/Alt-Shift-L) [#1674]
- Definition field on composer biological relationship task [#1672]

### Changed
- Unified can_destroy/edit methods
- Improved Source autocomplete with metadata/markup [#1681]
- Changed CoLDP download to use Catalog::Nomenclature as name source
- Replace SimpleMDE for EasyMDE
- Sort alphabetically bibliography style list on filter source
- Removed limit of download bibtex on filter source [#1683]
- Disable/enable destroy button from metadata on radial navigator [#1696]

### Fixed
- Non admins not able to destroy shared data [#1098]
- Pending confirmation: Include original combinations in CoLDP [#1204] 
- Pending confirmation: Include forma/variety properly in CoLDP [#1203] 
- Docker: Fixed path typo on clean up command
- Tag button on filter source [#1692]
- Overflow in taxon names list in new taxon name [#1688]
- Confidence button overlapped in new combination [#1687]

[#1098]: https://github.com/SpeciesFileGroup/taxonworks/issues/1098 
[#1672]: https://github.com/SpeciesFileGroup/taxonworks/issues/1672
[#1673]: https://github.com/SpeciesFileGroup/taxonworks/issues/1673
[#1674]: https://github.com/SpeciesFileGroup/taxonworks/issues/1674
[#1681]: https://github.com/SpeciesFileGroup/taxonworks/issues/1681
[#1203]: https://github.com/SpeciesFileGroup/taxonworks/issues/1203
[#1204]: https://github.com/SpeciesFileGroup/taxonworks/issues/1204
[#1672]: https://github.com/SpeciesFileGroup/taxonworks/issues/1672
[#1675]: https://github.com/SpeciesFileGroup/taxonworks/issues/1675
[#1683]: https://github.com/SpeciesFileGroup/taxonworks/issues/1683
[#1687]: https://github.com/SpeciesFileGroup/taxonworks/issues/1687
[#1688]: https://github.com/SpeciesFileGroup/taxonworks/issues/1688
[#1692]: https://github.com/SpeciesFileGroup/taxonworks/issues/1692
[#1696]: https://github.com/SpeciesFileGroup/taxonworks/issues/1696

## [0.12.16] - 2020-08-24

### Added
- Highlight metadata that is not in this project in uniquify people task [#1648]
- Locks buttons on grid digitizer task [#1599]
- Option to export styled bibliography on filter sources task [#1652]
- Edit button in content section on radial object [#1670]

### Changed
- Drag button style on new taxon name [#1669]
- Removed SimpleMDE lib from ruby assets and added to npm dependencies
- Allow taxon name type relationships to be cited [#1667]

### Fixed
- BibTex html no longer escaped [#1657]
- Some of the elements of the form are not accessible on overflow. [#1661]
- Populate masculine, feminine and neuter on gender form [#1665]
- Markdown render on Browse OTU [#1671]

[#1599]: https://github.com/SpeciesFileGroup/taxonworks/issues/1599
[#1648]: https://github.com/SpeciesFileGroup/taxonworks/issues/1648
[#1652]: https://github.com/SpeciesFileGroup/taxonworks/issues/1652
[#1657]: https://github.com/SpeciesFileGroup/taxonworks/issues/1657
[#1661]: https://github.com/SpeciesFileGroup/taxonworks/issues/1661
[#1665]: https://github.com/SpeciesFileGroup/taxonworks/issues/1665
[#1667]: https://github.com/SpeciesFileGroup/taxonworks/issues/1667
[#1669]: https://github.com/SpeciesFileGroup/taxonworks/issues/1669
[#1670]: https://github.com/SpeciesFileGroup/taxonworks/issues/1670
[#1671]: https://github.com/SpeciesFileGroup/taxonworks/issues/1671

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

[unreleased]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.16.4...development
[0.16.4]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.16.3...v0.16.4
[0.16.3]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.16.2...v0.16.3
[0.16.2]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.16.1...v0.16.2
[0.16.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.16.0...v0.16.1
[0.16.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.15.1...v0.16.0
[0.15.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.15.0...v0.15.1
[0.15.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.14.1...v0.15.0
[0.14.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.14.0...v0.14.1
[0.14.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.13.0...v0.14.0
[0.13.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.12.17...v0.13.0
[0.12.17]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.12.16...v0.12.17
[0.12.16]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.12.15...v0.12.16
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
