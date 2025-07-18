# Changelog

All (hopefully) notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
This project <em>does not yet</em> adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) as the API is evolving and MINOR patches may be backwards incompatible.

## [unreleased]

### Added

- Browse OTU: `collection objects` and `field occurrences` sounds

### Fixed

- CSD: Search autocomplete doesnt't work [#4481]
- CSD: Next by ID and Identifier don't work [#4480]
- Trying to delete the Collecting Event of a Field Occurrence now reports an error rather than causing an exception
- Drawing a new Gazetteer shape over an existing shape while zoomed in sometimes causes a zoom out [#4483]
- Batch source interface: Sources are not added to the project after create them [#4478]
- Filters: Light mode shows up in dark mode in by attributes facet [#4486]

[#4478]: https://github.com/SpeciesFileGroup/taxonworks/issues/4478
[#4480]: https://github.com/SpeciesFileGroup/taxonworks/issues/4480
[#4481]: https://github.com/SpeciesFileGroup/taxonworks/issues/4481
[#4483]: https://github.com/SpeciesFileGroup/taxonworks/issues/4483
[#4486]: https://github.com/SpeciesFileGroup/taxonworks/issues/4486

## [0.52.2] - 2025-07-11

### Added

- Radial mass annotatior: Add `is original` to citations slice
- New FO: `Lock/Unlock all` shortcut
- Filter taxon name relationship: Add slices to radial filter for taxon name subject/object [#4461]
- The following facets to Filter Images: Creator, Editor, Owner, Copyright holder, Source, License, Copyright Year, Depiction caption [#3511]
- Add with/without origin citation facet to Filter Taxon Name Relationships
- Radial mass annotator: `is original` flag option in batch citation [#4458]
- Filter Observations: Sounds facet
- Add 'include_common_names' parameter to API Otu autocomplete
- DwC import task: Detect and highlight columns that will be ignored [#4406]
- Project data export task: Recent download table [#4470]
- Field synchronize: Object label column [#4477]
- Custom password option for database exports [#4476]
- FieldOccurrence tab for subject/object on New Biological Association task
- Rebuild set index for dwc_occurrences

### Fixed

- Soft validation fix for combinations of plant names.
- Soft validation "Fix" buttons not working [#4450]
- Error radius not rendering in Georeference panel [#4448]
- Issues pop-up screen not rendering properly [#4447]
- Prevent cycles in SerialChronology (no accompanying data migration, remove bad data manually)
- Biocuration lock "lost" when rapidly creating records [#4415]
- Depiction list isn't populated in Image's depictions quick form [#4465]
- Specimens lots failing to generate DwC indexing in DwC importer [#4466]
- Filters: Sometimes sort column button doesn't work [#4442]
- Filter Taxon Names to Gender Summary fails with too many ids [#4479]
- Filter Asserted Distributions doesn't return all results for some spatial shapes [#4464]

### Changed

- Gazetteer shapes can now be added to/removed after save [#4399]
- Rename `Content by nomenclature ("Brock")` to `Content by taxon names ("Brock")`
- Rename `Download nomenclature (basic)` to `Download taxon names (basic)`
- Rename `Nomenclature stats` to `Taxon names stats`
- Rename `Synchronize nomenclature and OTUs` to `Synchronize taxon names and OTUs`
- Topic facet: Show all topics in a modal [#4456]
- Updated Ruby gems
- Field Synchronize and multi update task now sorts by ID url parameter [#4472]

[#3511]: https://github.com/SpeciesFileGroup/taxonworks/issues/3511
[#4399]: https://github.com/SpeciesFileGroup/taxonworks/issues/4399
[#4406]: https://github.com/SpeciesFileGroup/taxonworks/issues/4406
[#4415]: https://github.com/SpeciesFileGroup/taxonworks/issues/4415
[#4442]: https://github.com/SpeciesFileGroup/taxonworks/issues/4442
[#4447]: https://github.com/SpeciesFileGroup/taxonworks/issues/4447
[#4448]: https://github.com/SpeciesFileGroup/taxonworks/issues/4448
[#4450]: https://github.com/SpeciesFileGroup/taxonworks/issues/4450
[#4456]: https://github.com/SpeciesFileGroup/taxonworks/issues/4456
[#4458]: https://github.com/SpeciesFileGroup/taxonworks/issues/4458
[#4461]: https://github.com/SpeciesFileGroup/taxonworks/issues/4461
[#4464]: https://github.com/SpeciesFileGroup/taxonworks/issues/4464
[#4465]: https://github.com/SpeciesFileGroup/taxonworks/issues/4465
[#4466]: https://github.com/SpeciesFileGroup/taxonworks/issues/4466
[#4470]: https://github.com/SpeciesFileGroup/taxonworks/issues/4470
[#4472]: https://github.com/SpeciesFileGroup/taxonworks/issues/4472
[#4477]: https://github.com/SpeciesFileGroup/taxonworks/issues/4477
[#4479]: https://github.com/SpeciesFileGroup/taxonworks/issues/4479
[#4476]: https://github.com/SpeciesFileGroup/taxonworks/pull/4476

## [0.52.1] - 2025-06-17

### Added

- Filter asserted distributions: OTU Radial to table results
- New OTU task: Recent list [#4413]
- Sound size summary to Admin user activity task
- Multi-update DA task: Allow empty cell pasting [#4436]
- Created and updated dates to DwC import cards [#4439]

### Changed

- Rename `Browse nomenclature and classification` to `Browse taxon names`
- Rename `Filter nomenclature` to `Filter taxon names`
- Rename `Nomenclature match` to `Match taxon names`
- Rename `collection object match` to `Match collection objects`
- DwC import task: display imports from newest to oldest [#4441]

### Fixed

- Organization related Attribution validation [#4433]
- Gender summary task (linked from `Filter taxon names`)
- GeographicArea is missing on Georeference modal [#4420]
- Saved GeoLocate georeferences are missing on Georeference modal [#4422]
- Filters: Data attributes display in filter results even if they are not selected in custom layout [#4424]
- Field synchronize task doesn't work when you open it from Filter people [#4425]
- Collecting event form: CE generate label not working when there aren't collectors [#4434]

[#4433]: https://github.com/SpeciesFileGroup/taxonworks/issues/4433
[#4413]: https://github.com/SpeciesFileGroup/taxonworks/issues/4413
[#4420]: https://github.com/SpeciesFileGroup/taxonworks/issues/4420
[#4422]: https://github.com/SpeciesFileGroup/taxonworks/issues/4422
[#4370]: https://github.com/SpeciesFileGroup/taxonworks/issues/4370
[#4424]: https://github.com/SpeciesFileGroup/taxonworks/issues/4424
[#4425]: https://github.com/SpeciesFileGroup/taxonworks/issues/4425
[#4434]: https://github.com/SpeciesFileGroup/taxonworks/issues/4434
[#4436]: https://github.com/SpeciesFileGroup/taxonworks/issues/4436
[#4439]: https://github.com/SpeciesFileGroup/taxonworks/issues/4439
[#4441]: https://github.com/SpeciesFileGroup/taxonworks/issues/4441

## [0.52.0] - 2025-06-09

### Added

- `cached_gender` and `cached_is_available` to TaxonName (eliminate many n+1 queries)
- Filter `TaxonNameRelationship`
- Tab options on Field Occurrence smart selectors (select_options)
- Radial Collecting event: Add remove geographic area option in `Set geographic area` slice [#4375]
- Filter sources: `With/without pages` facet [#4374]
- Field occurrences facet to Filter images
- Field occurrences to biological associations graph task
- Field occurrences to observation matrices
- New Field occurrences: Reorder fields
- Browse OTU: Depictions to `Field occurrences` and `Specimen records` panels
- Identifier batch annotator to Filter Collecting event and Collection object
- 'Ignore pagination' option to Venn facet of filters [#4390]
- New filter for Taxon Name Relationships
- General verifier facet
- `.text_tree` rendering for TaxonName instances
- Help for new OTU fields
- Task - Filter Nomenclature - TaxonName relationship without citation. [#4010]
- Browse OTU: Sort buttons to Asserted distributions table [#4411]

### Changed

- Updated Ruby gems
- Updated layout of data and internal attribute facets
- Remove unused GeographicItem columns
- Optimizes a lot of nomenclature related SQL, removing, for example, unnecessary ordering
- A massive speedup of the CoLDP export across the board, ~25x
- `ORIGINAL_COMBINATION_RANKS` to align with other constants
- Unifies `full_name_hash` return
- Filters: Selected records are kept if they appear in new searches [#4393]
- Refactored and unified collecting event form across all tasks
- Unified and improved some batch functions
- Disable CrossRef and BibTeX only when created source has unsaved changes [#4405]
- Switch shape geo_json type attribute value from snake to Pascal
- Improve performance of DwC importer vs. georeference related data
- Tweaks to Biodiversity wrapper to better handle subgenera
- Begins to isolate and unify Protonym name formatting code (`protonym/format.rb`)
- Better `.heic` image support.
- Better Container autocomplete
- New taxon name: Moved checkboxes next to names in Manage synonyms [#4414]

### Fixed

- TaxonName `cached_classified_as` built with space [#4373]
- Temperature units
- Unify task: No message error is displayed when merging fails
- New field occurrence task: Collecting event radials don't work on new CE [#4354]
- Filter Collecting event: Data attributes layout [#4355]
- Radial Collecting event: error radius is not copy on `Set Georeference` slice [#4358]
- Filter Collection object: Results are not displayed when DwC information is missing
- New Asserted Distribution task can't create more than one Asserted distribution on a given OTU [#4388]
- Radial filter: When opening a filter link in a new tab, the filter page loads empty when the URL is too long [#4360]
- Smart selectors don't refresh on new Collecting event and new Field occurrence after save
- Import DwC slowdown (thanks for reporting Davide)
- Filter Collecting event: "In range (Integers)" missing data [#4387]
- Searching by Data Attribute can fail to find some/all [#4365]
- Browse OTU: The map render each asserted distribution shape in a different color [#4404]
- Filters: Radial navigator overlaps when columns are locked [#4408]
- API identifies more OTUs in key related responses

[#4010]: https://github.com/SpeciesFileGroup/taxonworks/issues/4010
[#4354]: https://github.com/SpeciesFileGroup/taxonworks/issues/4354
[#4355]: https://github.com/SpeciesFileGroup/taxonworks/issues/4355
[#4358]: https://github.com/SpeciesFileGroup/taxonworks/pull/4358
[#4360]: https://github.com/SpeciesFileGroup/taxonworks/issues/4360
[#4360]: https://github.com/SpeciesFileGroup/taxonworks/issues/4365
[#4373]: https://github.com/SpeciesFileGroup/taxonworks/issues/4373
[#4374]: https://github.com/SpeciesFileGroup/taxonworks/issues/4374
[#4375]: https://github.com/SpeciesFileGroup/taxonworks/issues/4375
[#4387]: https://github.com/SpeciesFileGroup/taxonworks/issues/4387
[#4388]: https://github.com/SpeciesFileGroup/taxonworks/issues/4388
[#4390]: https://github.com/SpeciesFileGroup/taxonworks/issues/4390
[#4393]: https://github.com/SpeciesFileGroup/taxonworks/issues/4393
[#4404]: https://github.com/SpeciesFileGroup/taxonworks/pull/4404
[#4408]: https://github.com/SpeciesFileGroup/taxonworks/issues/4408
[#4411]: https://github.com/SpeciesFileGroup/taxonworks/issues/4411
[#4414]: https://github.com/SpeciesFileGroup/taxonworks/issues/4414

## [0.51.0] - 2025-05-16

### Added

- `Gazetteer` model - custom geospatial shapes for your project [#1954]
- Matrix radial to Sound and FieldOccurrence filters
- Celsius and Hertz quantitative units to Descriptors
- Batch georeference on Filter CE [#4336]
- New content task: Publish content button
- Batch georeference on Filter CE [#4336]
- Send Filter Field Occurrence results to Filter Image, and vice versa [#4348]
- Add Field Occurrence as an option to more facets in Filter Images and Filter Observations
- Send filter results between Observations and: field occurrences, extracts, and sounds

### Changed

- Asserted Distributions returned by the `/api/v1/asserted_distributions.json` endpoint include distributions based on both Geographic Areas and Gazetteers (new). You can check the type of each distribution using the new type key of the distribution record: `{type: 'GeographicArea' or 'Gazetteer', ... }`
- Improved performance on cached map building and spatial filtering
- Removed Match geoference task [#4336]
- Updated Ruby gems
- Updated NPM packages
- Radial CO: Increase Taxon Determinations batch load limit to 5000 [#4349]

### Fixed

- Project not required for batch add users [#4327]
- Repository edits trigger DwcOccurrence updates [#4342]
- Observation matrix OTU content exception
- Syncronize nomenclature/OTUs task initialization
- Filters: pop up screen overlap when columns are locked [#4322]
- Browse Otu: display verbatimLocality in Specimen Records section [#4331]
- CSD: Missing Georeferences when collecting_event_id is passed by parameter [#4339]
- Background mass annotate Confidence or Protocol Relationship on >300 filter results [#4344]

[#1954]: https://github.com/SpeciesFileGroup/taxonworks/issues/1954
[#4327]: https://github.com/SpeciesFileGroup/taxonworks/issues/4327
[#4342]: https://github.com/SpeciesFileGroup/taxonworks/issues/4342
[#4336]: https://github.com/SpeciesFileGroup/taxonworks/issues/4336
[#4322]: https://github.com/SpeciesFileGroup/taxonworks/issues/4322
[#4331]: https://github.com/SpeciesFileGroup/taxonworks/issues/4331
[#4339]: https://github.com/SpeciesFileGroup/taxonworks/issues/4339
[#4334]: https://github.com/SpeciesFileGroup/taxonworks/issues/4344
[#4348]: https://github.com/SpeciesFileGroup/taxonworks/issues/4348
[#4349]: https://github.com/SpeciesFileGroup/taxonworks/issues/4349

## [0.50.1] - 2025-05-01

### Added

- TaxonName filter report summarizing gender in a table
- Tooltips on various radials
- More DwC fields for FieldOccurrences

### Changed

- Improved data overview graphs, options
- Further improvements to Container metadata display
- Update Rubygems
- Update NPM packages
- Improved some auto-focus behaviour

### Fixed

- Various filter Content fixes
- Various Batch/Mass annotator fixes
- Browse collecting event fails to load
- A TaxonDetermination related filter parameter issue
- TaxonDetermination related issues on FieldOccurrence and CollectionObject
- When Sounds fail to destroy the error is not caught
- Unify fails to activate [#4310]
- Unify fails to merge FieldOccurrences [#4315]
- Repositories shouldn't try to render Citations
- Pdf download of formatted sources
- 500 on filter mass annotate for an annotation not supported on the model [#4307]

[#4307]: https://github.com/SpeciesFileGroup/taxonworks/issues/4307
[#4310]: https://github.com/SpeciesFileGroup/taxonworks/issues/4310
[#4315]: https://github.com/SpeciesFileGroup/taxonworks/issues/4315

## [0.50.0] - 2025-04-24

### Added

- `decorator_status` to `api/v1/taxon_names/:id/inventory/summary`
- Radial annotator and navigator to role picker list
- CSD: Highlight header bar when DwC re-index is pending [#4275]
- New source task: Citations count [#4237]
- Allow catalog number to start with zeros in Grid digitizer task [#4291]
- Filter collection objects: Extend response to include container item [#4285]
- Browse Nomenclature: Focus button [#4283]
- Sounds and conveyances. Browse, filter, new from radial. [#244]

### Changed

- Browse OTU: Specimen records are displayed on DwC table [#4138]
- Updated Ruby gems

### Fixed

- Eliminate 404 behaviour in Synchronize nomenclature [#4284]
- Filter CollectingEvent to OTU Filter linkage broken [#4277]
- Filter OTU CSV download ommitted OTUs with no taxon name
- DwcOccurrence FieldOccurrence scoping
- TypeMaterial hook to DwcOccurrence update [#4266]
- Georeferences in the CollectingEvent section of FieldOccurrence don't reset when the CollectingEvent is reset [#4274]
- Filter tasks: Back to Field Occurrence filter from nested parameters modal doesn't work [#4278]
- Content editor: Close modal is enable when nothing is selected [#4279]
- Radials from facets side are enabled when no filters are active [#4281]
- Some identifiers are missing on DwC otherCatalogNumbers column
- Identifiers cached is empty in CSV table
- DwC importer creating sex biocuration group with an array as URI
- Filters: Sorting alphabetically does not work correctly when values are in HTML

[#4266]: https://github.com/SpeciesFileGroup/taxonworks/issues/4266
[#4284]: https://github.com/SpeciesFileGroup/taxonworks/issues/4284
[#4277]: https://github.com/SpeciesFileGroup/taxonworks/issues/4277
[#244]: https://github.com/SpeciesFileGroup/taxonworks/issues/244
[#4138]: https://github.com/SpeciesFileGroup/taxonworks/issues/4138
[#4237]: https://github.com/SpeciesFileGroup/taxonworks/issues/4237
[#4274]: https://github.com/SpeciesFileGroup/taxonworks/issues/4274
[#4275]: https://github.com/SpeciesFileGroup/taxonworks/issues/4275
[#4278]: https://github.com/SpeciesFileGroup/taxonworks/issues/4278
[#4279]: https://github.com/SpeciesFileGroup/taxonworks/issues/4279
[#4281]: https://github.com/SpeciesFileGroup/taxonworks/issues/4281
[#4283]: https://github.com/SpeciesFileGroup/taxonworks/issues/4283
[#4285]: https://github.com/SpeciesFileGroup/taxonworks/issues/4285
[#4291]: https://github.com/SpeciesFileGroup/taxonworks/issues/4291

## [0.49.1] - 2025-04-01

### Added

- Offset parameter to copy_table_to_clipboard helper [#4265]
- Collecting event metadata task (count of use, plot of time), via filter
- UI flag that a DwcOccurrence re-index is pending. [#4267]

### Fixed

- Min/max use of Collecting Event filter facet [#4252]
- Unify Otu failing because of CachedMap references
- Determiner is not carrying over in locked, containerized COs in CSD [#4250]
- Filter CO: blank fields dispersed among sort [#4255]
- Filter CO: otu name is empty in taxon determinations rows [#4257]
- Filter CE: some data attributes are missing from results [#4258]
- Filters: Download CSV doesn't use selected layout to generate files [#4264]

[#4252]: https://github.com/SpeciesFileGroup/taxonworks/issues/4252
[#4250]: https://github.com/SpeciesFileGroup/taxonworks/issues/4250
[#4255]: https://github.com/SpeciesFileGroup/taxonworks/issues/4255
[#4257]: https://github.com/SpeciesFileGroup/taxonworks/issues/4257
[#4258]: https://github.com/SpeciesFileGroup/taxonworks/issues/4258
[#4264]: https://github.com/SpeciesFileGroup/taxonworks/issues/4264
[#4265]: https://github.com/SpeciesFileGroup/taxonworks/issues/4265
[#4267]: https://github.com/SpeciesFileGroup/taxonworks/issues/4267

## [0.49.0] - 2025-03-18

### Added

- Cross link DwcOccurrence to Otu in filters (with fixes on others)
- `/api/v1/field_occurrences/:id/dwc`
- `/api/v1/otus/:id/inventory/determined_to_rank`
- Append mode to multi update data attributes task [#4204]
- <in progress Batch add/remove Protocols>
- Protocol `is_machine_output` attribute to facilitate `MachineObservation` types
- Batch change Protocol references
- Sticky navbar on browse nomenclature and collecting event
- Move button to citations and depiction slices in radial annotator
- Freeze column checkbox to filter tasks [#4220]
- Sort layout columns on filter tasks [#4219]
- Field occurrence panel to Browse OTU
- Field occurrence attributes to DwcOccurrence
- Browse field occurrence
- Filter field occurrences
- Field occurrences appear in OTU inventory endpoints
- Taxon names with gender filter facet
- Subject/object restrictions in filter nomenclature [#3094]

### Changed

- Filter attribute facet now more precise
- DwcOccurrence by `otu_id` now checks FieldOccurrence as well
- Updating a Person updates DwcOccurrence across projects
- All updates to DwcOccurrence are via delayed jobs
- Add total to unmatched panel on Nomenclature match task
- Prevent user destroy last saved TD on New FO task [#4225]
- Updated Ruby gems and Node packages
- Navigation bar layout

### Fixed

- SimpleMappr output for large results
- Synonymy section of Edit Nomenclature alphabetically sorted
- Duplicate CollectingEvents filtered when Collectors facet used
- FieldOccurrences not destroyable
- DwcOccurrences being updated out of scope
- Unescaped search strings on Project vocabulary
- `&sort=alphabetical|classification` param to `/taxon_names/`
- AssertedDistributions duplicating because of is_absent state [#4226]
- `verbatim_label` not batch loading to "Castor" form [#4230]
- Otu content export rendering exceptions
- ObservationMatrixColumItem show rendering
- Rendering of Identifier::Local::RecordNumber
- Reset button is not working on Unify people
- Import dataset description uniqueness validation failing to detect duplicate
- CSD: It is not possible to add new taxon determinations to an existing CO [#4227]
- New FO, CE Panel: Saved identifiers aren't loaded in the UI on page reload [#4241]
- Unify object task: reset button doesn't clear autocompletes [#4242]
- Capybara/Chrome testing
- Venn queries with nested elements (candidate fix) [#4224], [#3983]

[#3094]: https://github.com/SpeciesFileGroup/taxonworks/issues/3094
[#4226]: https://github.com/SpeciesFileGroup/taxonworks/issues/4226
[#4230]: https://github.com/SpeciesFileGroup/taxonworks/issues/4230
[#4204]: https://github.com/SpeciesFileGroup/taxonworks/issues/4204
[#4219]: https://github.com/SpeciesFileGroup/taxonworks/issues/4219
[#4220]: https://github.com/SpeciesFileGroup/taxonworks/issues/4220
[#4225]: https://github.com/SpeciesFileGroup/taxonworks/issues/4225
[#4224]: https://github.com/SpeciesFileGroup/taxonworks/issues/4224
[#3983]: https://github.com/SpeciesFileGroup/taxonworks/issues/3983
[#4227]: https://github.com/SpeciesFileGroup/taxonworks/issues/4227
[#4241]: https://github.com/SpeciesFileGroup/taxonworks/pull/4241
[#4242]: https://github.com/SpeciesFileGroup/taxonworks/issues/4242

## [0.48.0] - 2025-02-14

### Added

- Browse Field Occurrence task [#4200]
- Help for Project Vocabulary task UI fields [#4192]

### Changed

- Sort asserted distributions alphabetically in Quick Forms
- Update taxon nomenclatural date after source update
- Updated Ruby Gems

### Fixed

- Failure to set `dwc_occurrences` for rebuild for background processing
- New collecting event task: Identifier panel sets and displays an incorrect identifier number [#4208]
- Comprehensive digitization sometimes failing to save identifiers [#4206]
- Bad link when creating a synonym where the old name has children and then clicking the green edit button in Edit Taxon Name [#4196]
- Taxon names not being displayed in relationships facet of Filter Nomenclature task. [#4193]

[#4208]: https://github.com/SpeciesFileGroup/taxonworks/issues/4208
[#4206]: https://github.com/SpeciesFileGroup/taxonworks/pull/4206
[#4196]: https://github.com/SpeciesFileGroup/taxonworks/pull/4196
[#4193]: https://github.com/SpeciesFileGroup/taxonworks/pull/4193
[#4192]: https://github.com/SpeciesFileGroup/taxonworks/pull/4192
[#4200]: https://github.com/SpeciesFileGroup/taxonworks/pull/4200

## [0.47.0] - 2025-02-06

### Added

- Use Rails 7.2 and Ruby 3.3.6
- New image task: Add field occurrence to depict some list [#4135]
- Grab cursor to make sorting feature visible [#4153]
- API endpoint for image matrix
- Order of depictions coming from the image matrix
- Hub tasks: Add visual effect for fav icons and tooltip for categories [#4177]
- Distribution to COLDP exports [#3148]
- Taxon links to COLDP exports
- SpeciesInteraction to COLDP exports [#3158]
- Specs and optimizations to COLDP
- Pull metadata from ChecklistBank in order to merge updated metadata into COLDP exports
- Filter's match identifiers facet can now be quickly accessed with `shift-ctrl-m` in a modal form
- `gift` facet to Filter loans.
- Multi data attribute update task [#4142]
- Keys are now multifurcatable [#4148]
- Identical Document validation
- Some inline help and visual improvements [#4177]
- Keys can be cloned, merged, and inserted to [#4056]
- API endpoint for serving Image matrices

### Changed

- Match identifiers defaults to match Identifier, not internal, `\n`, and caseless match [#4176]
- Added Gift status notices to loans form [#4174]
- Improved and clarified DwcOccurrence indexing concepts and application
- Improved writing to cached\* fields for TaxonName

### Fixed

- Fixes to TaxonWorks CSL style
- Bug in Image autocomplete
- CatalogNumbers attached to Containers not appearing in CollectionObject tag [#4163]
- OriginRelationship creation for Sequences [#4180]
- CSD: change of namespace not updating [#4147]
- TaxonWorks bibliography style for book chapter.
- Removed obsolete Description table from COLDP exports
- Remove [sic] from COLDP name fields [#3833]
- Autonym synonyms bug in COLDP exporter [#4175]
- New taxon name: Show only subject relationships on Relationships section
- Images added before saving field occurrence are not saved [#4134]
- Rendering Family group names from invalid names [#4187]
- Verbatim latitude not displaying [#4178]

[#4056]: https://github.com/SpeciesFileGroup/taxonworks/issues/4056
[#4177]: https://github.com/SpeciesFileGroup/taxonworks/issues/4177
[#4178]: https://github.com/SpeciesFileGroup/taxonworks/issues/4178
[#4148]: https://github.com/SpeciesFileGroup/taxonworks/issues/4148
[#4163]: https://github.com/SpeciesFileGroup/taxonworks/issues/4163
[#4174]: https://github.com/SpeciesFileGroup/taxonworks/issues/4174
[#4176]: https://github.com/SpeciesFileGroup/taxonworks/issues/4176
[#4180]: https://github.com/SpeciesFileGroup/taxonworks/issues/4180
[#3148]: https://github.com/SpeciesFileGroup/taxonworks/issues/3148
[#3158]: https://github.com/SpeciesFileGroup/taxonworks/issues/3158
[#3833]: https://github.com/SpeciesFileGroup/taxonworks/issues/3833
[#4134]: https://github.com/SpeciesFileGroup/taxonworks/issues/4134
[#4135]: https://github.com/SpeciesFileGroup/taxonworks/issues/4135
[#4142]: https://github.com/SpeciesFileGroup/taxonworks/issues/4142
[#4147]: https://github.com/SpeciesFileGroup/taxonworks/issues/4147
[#4153]: https://github.com/SpeciesFileGroup/taxonworks/issues/4153
[#4175]: https://github.com/SpeciesFileGroup/taxonworks/issues/4175
[#4177]: https://github.com/SpeciesFileGroup/taxonworks/issues/4177
[#4187]: https://github.com/SpeciesFileGroup/taxonworks/issues/4187

## [0.46.1] - 2024-12-04

### Fixed

- Add citation back to gallery endpoint [#4136]

[#4136]: https://github.com/SpeciesFileGroup/taxonworks/issues/4136

## [0.46.0] - 2024-12-03

### Added

- Added soft_validation of infrasubspecific name.
- Topics can be unified [#4106]
- Task - Controlled vocabulary terms across projects [#4112]
- Source filter can operate on `cached_*` fields enabling link to project vocabulary [#4123]
- `/api/v1/otus/:id/inventory/images?sort_order=` param to sort by class of Depiction object type
- Task - Simplemappr (https://www.simplemappr.net) export support from Filter collection objects
- Print key task [#4071] [#4117]
- `/api/v1/leads/key/:id` endpoint serving `pinpoint` key app
- Filter loans: Identifiers, created by and updated by columns [#4098]
- Edit/New loan task: Add `none` status option
- Edit/New Field occurence task: biological associations panel [#4103]
- Edit/New Field occurence task: depictions panel [#4108]
- Matrix row coder task: Now and Today lock buttons [#4110]
- More TaxonName soft validations

### Fixed

- `/api/v1/otus/:id/inventory/images` out of context depictions [#4129]
- Unifying related BiologicalAssociations [#4099]
- Async DwcOccurrence refreshes that referenced destroyed objects
- FieldOccurrence Radial Navigator
- Unify objects: Same object can be selected on both sides [#4100]
- New taxon name: Cannot create new combination (under ICN) [#4127]
- Syncronize misspellings [#4109]
- Blank terms to /autocomplete endpoints raising
- Rendering subspecies names in botany
- TypeMaterial autocomplete
- Some async DwcOccurrence updating callbacks

### Changed

- `/api/v1/otus/:id/inventory/images` response structure
- Update Gemfiles

[#4109]: https://github.com/SpeciesFileGroup/taxonworks/issues/4109
[#4106]: https://github.com/SpeciesFileGroup/taxonworks/issues/4106
[#4112]: https://github.com/SpeciesFileGroup/taxonworks/issues/4122
[#4123]: https://github.com/SpeciesFileGroup/taxonworks/issues/4123
[#4129]: https://github.com/SpeciesFileGroup/taxonpages/issues/4129
[#4099]: https://github.com/SpeciesFileGroup/taxonworks/issues/4099
[#4117]: https://github.com/SpeciesFileGroup/taxonworks/issues/4117
[#4071]: https://github.com/SpeciesFileGroup/taxonworks/issues/4071
[#4098]: https://github.com/SpeciesFileGroup/taxonworks/issues/4098
[#4100]: https://github.com/SpeciesFileGroup/taxonworks/issues/4100
[#4103]: https://github.com/SpeciesFileGroup/taxonworks/issues/4103
[#4108]: https://github.com/SpeciesFileGroup/taxonworks/issues/4108
[#4110]: https://github.com/SpeciesFileGroup/taxonworks/issues/4110
[#4127]: https://github.com/SpeciesFileGroup/taxonworks/issues/4127

## [0.45.0] - 2024-10-30

### Added

- Created/updated overviews for user data
- Unify objects task [#970]
- Attribution to ObservationMatrix
- New biological association task [#4026]
- Duplicate OTU predictor task [#4083]
- DwcOccurrenceHooks for BiocurationGroups, OTUs
- New image task: is original checkbox to source panel [#4090]
- Confidence facets and batch operations to all Filters [#4043]
- Browse nomenclature task: Radial annotator for OTUs

### Changed

- RecordNumber identifiers can be duplicated (namespace + identifier combinations) across CollectionObjects [#4096]
- Local identifier display in CollectionObject tag now prefers position to break tie with RecordNumber and CatalogNumber [#4074]
- Filter CO: Show only current taxon determination [#4092]

### Fixed

- Loan OTU facet [#4087]
- With/out facets failing in combination with other facets [#4089]
- Simple TaxonName batch load failing with invalid children
- `api/v1/images/:id` broken for non-integer ids
- Containerizing objects prevented identific increments
- New dichotomous key: Radial annotator is not loading the correct data [#4076]

[#4087]: https://github.com/SpeciesFileGroup/taxonworks/issues/4087
[#4089]: https://github.com/SpeciesFileGroup/taxonworks/issues/4089
[#4026]: https://github.com/SpeciesFileGroup/taxonworks/issues/4026
[#4043]: https://github.com/SpeciesFileGroup/taxonworks/issues/4043
[#4074]: https://github.com/SpeciesFileGroup/taxonworks/issues/4074
[#4076]: https://github.com/SpeciesFileGroup/taxonworks/issues/4076
[#4077]: https://github.com/SpeciesFileGroup/taxonworks/issues/4077
[#4083]: https://github.com/SpeciesFileGroup/taxonworks/issues/4083
[#4090]: https://github.com/SpeciesFileGroup/taxonworks/issues/4090
[#4092]: https://github.com/SpeciesFileGroup/taxonworks/issues/4092
[#4096]: https://github.com/SpeciesFileGroup/taxonworks/issues/4096
[#970]: https://github.com/SpeciesFileGroup/taxonworks/issues/970

## [0.44.3] - 2024-10-03

### Added

- `dwc_occurrence_id[]` param to dwc_gallery endpoint
- Image matrix link to radial linker and radial matrix

### Fixed

- Date received facet on loans [#4067]
- `api/v1/images/975145cf4d25d7ed35893170abc2e852` style calls finding images by id, not fingerprint [#3918]

### Changed

- Updated Ruby gems
- In DwC Import Otu `name` is now only set via use of `identificationQualifier`

[#3918]: https://github.com/SpeciesFileGroup/taxonworks/issues/3918
[#4067]: https://github.com/SpeciesFileGroup/taxonworks/issues/4067

## [0.44.2] - 2024-09-27

### Added

- Columns in filter results can be copied to clipboard
- Sort by identifier match option [#4065]
- `/collection_objects/123/dwc_compact` - DwC fields for those populated [#3994]
- Pagination to `/api/v1/otus/:otu_id/inventory/dwc_gallery`

### Fixed

- Display of missing DwC fields [#4051]
- `verbatim_field_number` updates ignored [#4066]
- DwC importer `verbatim_field_number` collision with Identifier validation
- Shortcuts: Keys pressed are not removed after user switches windows/tab

[#4065]: https://github.com/SpeciesFileGroup/taxonworks/issues/4065
[#4051]: https://github.com/SpeciesFileGroup/taxonworks/issues/4051
[#4066]: https://github.com/SpeciesFileGroup/taxonworks/issues/4066
[#3994]: https://github.com/SpeciesFileGroup/taxonworks/issues/3994

## [0.44.1] - 2024-09-24

### Added

- `/api/v1/otus/:id/inventory/keys` a list of keys scoped to or containing the Otu
- `otu_id` to ObservationMatrix, to facilitate setting scope and indexing of multi-entry keys
- `is_public` flag to ObservationMatrix

### Changed

- Revert strict `verbatim_field_number` validation [#4061]
- Renamed CollectingEvent `verbatim_trip_identifier` to `verbatim_field_number` [#4058]

### Fixed

- DwC `eventDate` should not be populated without an explict year reference [#4053]
- DwC `month` should not be populated when range-provided [#4055]

[#4053]: https://github.com/SpeciesFileGroup/taxonworks/issues/4053
[#4055]: https://github.com/SpeciesFileGroup/taxonworks/issues/4055
[#4058]: https://github.com/SpeciesFileGroup/taxonworks/issues/4058
[#4061]: https://github.com/SpeciesFileGroup/taxonworks/issues/4061

## [0.44.0] - 2024-09-17

### Added

- Create container task [#3038]
- Endpoint crossreferencing dwc_occurrences and images `api/v1/otus/:otu_id/inventory/dwc_gallery.json?per=1&page=2`
- Creating depictions of CollectionObjects now updates their DwcOccurrence automatically
- Filters: Custom button to `records per page` selector [#4032]
- New asserted distribution: Confidence panel [#4044]

### Changed

- Updated Ruby gems

### Fixed

- DwcOccurrence now _actually_ selects the valid name on export
- OTU taxonomy inventory API endpoint crashing on protonyms with no cached year and author.
- DwC importer column indexing confusion when there are blank headers
- Filter collecting event: Remove duplicate radial linker [#4050]

[#3038]: https://github.com/SpeciesFileGroup/taxonworks/issues/3038
[#4032]: https://github.com/SpeciesFileGroup/taxonworks/issues/4032
[#4044]: https://github.com/SpeciesFileGroup/taxonworks/issues/4044
[#4050]: https://github.com/SpeciesFileGroup/taxonworks/issues/4050

## [0.43.3] - 2024-09-09

### Added

- `per` and `page` parameters to `/api/v1/otus/:id/inventory/dwc`
- With/out facets for Loan dates [#3729]
- FieldNumber local identifier sensu DwC
- RecordNumber local identifier sensu DwC [#4016]
- DwC importer support for FieldNumber and RecordNumber [#4016] [#3800]
- DwC export support for FieldNumber, RecordNumber
- New RecordNumber panel for Comprehensive Digization
- Filter Otu: With/without common names
- Radial annotator: Add sort to identifiers slice [#4021]
- `extend[]=valid_name` to `/taxon_names`
- Valid name column in filter nomenclature

### Changed

- DwC export will now use a valid taxon name if linked first to an invalid, and it is available
- EventID and verbatim_trip_identifier are disentangled in DwC Importer, they do not map to one-another now [#3800] [#2852]
- TripCode is now FieldNumber (all data migrated)
- DwcOccurrence rebuilds triggered for changes to TaxonNameRelationship [#4019], TypeMaterial, TaxonDetermination, Identifier::Global
- Wikidata IDs are now also loaded into recordedByID and identifiedByID [#3989]
- Sort order of descendant inventory
- Removed net-pop gem workaround for Ruby 3.3.3
- Facet geographic area: Spatial mode by default
- Facet nomenclature rank: Remove selected ranks from select input
- Updated Ruby gems
- New taxon name task: Add manual mode for subsequent combinations section when taxon rank is not in the list [#4009]
- Optimized performance of Combination name rendering and use
- Filters with Geographic area facet default to 'Spatial'

### Fixed

- Header labels print without higher taxonomy [#4030]
- Staged images tab on collection object report
- Non-integer identifier start/end ranges raising
- Various facets in Filter OTUs not being scoped to unique records
- Saving a bad identifier from annotator fails to show message why
- Download formatted references as PDF
- Quickly clicking save before load-in on Comprehensive can detach CollectingEvent from CollectionObject
- Filter collecting events: data attribute table view is empty [#4013]
- Field synchronize: URI Too Large error when user pass a long query [#4017]
- DwC importer crashing on record with blank `basisOfRecord` [#4024]

[#2852]: https://github.com/SpeciesFileGroup/taxonworks/issues/2852
[#3729]: https://github.com/SpeciesFileGroup/taxonworks/issues/3729
[#3800]: https://github.com/SpeciesFileGroup/taxonworks/issues/3800
[#3989]: https://github.com/SpeciesFileGroup/taxonworks/issues/3989
[#4009]: https://github.com/SpeciesFileGroup/taxonworks/issues/4009
[#4013]: https://github.com/SpeciesFileGroup/taxonworks/issues/4013
[#4016]: https://github.com/SpeciesFileGroup/taxonworks/issues/4016
[#4017]: https://github.com/SpeciesFileGroup/taxonworks/issues/4017
[#4018]: https://github.com/SpeciesFileGroup/taxonworks/issues/4018
[#4019]: https://github.com/SpeciesFileGroup/taxonworks/issues/4019
[#4021]: https://github.com/SpeciesFileGroup/taxonworks/issues/4021
[#4024]: https://github.com/SpeciesFileGroup/taxonworks/issues/4024
[#4030]: https://github.com/SpeciesFileGroup/taxonworks/issues/4030

## [0.43.2] - 2024-08-10

### Added

- `all` button to predicate selector in Field Synchronize [#4005]
- `recent_target` parameter to filters, one of `updated_at` (default) or `created_at` [#4004]
- `verbatim_name` facet to Filter Nomenclature
- Soft validation (and fix) identifying redudant use of `verbatim_name` in Combinations

### Changed

- Comprehensive Specimen Digitization: Prevent user add duplicate types for type materials [#4002]
- Improved visual differentiation of Sandboxes

### Fixed

- Fixed Loan rendering when `date_sent` is blank [#4001]
- New combination: Links in `Other matches`panel didn't work

[#4001]: https://github.com/SpeciesFileGroup/taxonworks/issues/4001
[#4002]: https://github.com/SpeciesFileGroup/taxonworks/issues/4002
[#4004]: https://github.com/SpeciesFileGroup/taxonworks/issues/4004
[#4005]: https://github.com/SpeciesFileGroup/taxonworks/issues/4005

## [0.43.1] - 2024-08-04

### Changed

- Updated gems

### Fixed

- Integer type checking impacting AssertedDistribution filter
- Editing DataAttributes trigger complete re-index of the DwcOccurences [#4000]
- Misspelled DwcOccurrence attribute

[#4000]: https://github.com/SpeciesFileGroup/taxonworks/issues/4000
[#4002]: https://github.com/SpeciesFileGroup/taxonworks/issues/4002

## [0.43.0] - 2024-07-31

### Added

- Task to add image and as depictions to the objects identified in their filename [#3986]
- PDF version of styled/formatted source download [#3996]
- Type checking pattern for integers sent to `*_id` params in the API
- Radial annotator: Pagination to depictions slice
- Comprehensive: Pagination to depictions panel
- Browse collection objects Pagination to depictions panel
- Filter source: add ID to list [#3984]
- TW_DISABLE_DEPLOY_UPDATE_DATABASE env var to disable DB backup and migration at deploy time.

### Changed

- `repositories/autocomplete` label [#3981]
- Updated Ruby gems

### Fixed

- TaxonName filter Original combination with/out facet (both with and without)
- Removed deprecated GoogleMap georeference form [#3991]
- Print label generation [#3992]
- Generating a TaxonWorks Download for a bibtex result failing [#3997]
- Removed bad foreign-key constraint on BiocurationClassifications, TaxonDeterminations
- Content autocomplete not scoped to projects
- Some hotkeys don't work on Firefox on Linux [#3988]
- Cancel previous autocomplete requests [#3982]

[#3984]: https://github.com/SpeciesFileGroup/taxonworks/issues/3984
[#3991]: https://github.com/SpeciesFileGroup/taxonworks/issues/3991
[#3981]: https://github.com/SpeciesFileGroup/taxonworks/issues/3981
[#3982]: https://github.com/SpeciesFileGroup/taxonworks/issues/3982
[#3986]: https://github.com/SpeciesFileGroup/taxonworks/issues/3986
[#3988]: https://github.com/SpeciesFileGroup/taxonworks/issues/3988
[#3992]: https://github.com/SpeciesFileGroup/taxonworks/issues/3992
[#3996]: https://github.com/SpeciesFileGroup/taxonworks/issues/3996
[#3997]: https://github.com/SpeciesFileGroup/taxonworks/issues/3997

### Fixed

- Handling of [sic] in Protonym#original_combination_infraspecific_element [#3867]

## [0.42.0] - 2024-06-28

### Added

- Nexus file import [#2029]
- POST `/annotations/move?from_global_id=<>&to_global_id=<>&only[]=&except[]=`
- Clone CollectingEvent can include annotations, incremented identifiers
- Model Identifier::Local::Event in part: [#3800]
- Task - DwcOccurrence status
- `/api/v1/taxon_names/origin_citation.csv`, taxon names plus their origin citation
- Reasonable min/max elevations hard validations
- Increased scope of string cleaning [#3947]
- DwcOccurrence filter on all attributes
- DwcOccurrence visible in Project vocabulary
- Confirmation modal on mass annotator [#3969]
- `TW_ACTION_MAILER_SMTP_SETTINGS_USER_NAME`, `TW_ACTION_MAILER_SMTP_SETTINGS_PASSWORD` and `TW_ACTION_MAILER_SMTP_SETTINGS_AUTHENTICATION_TYPE` env vars for container deployments

### Fixed

- CE batch update collectors [#3936]
- Broken BiologicalAssociation scope for DwC download [#3949]
- NeXML render to screen [#3961]
- People queries referencing `use_min` and `use_max` in combination with other facets
- `/observation_matrix_column/list`
- Queries referencing emtpy `identifier_start` or end failing
- Moving depiciton from an Otu could fail in some cases
- OTU inventory endpoint failing when synonyms are empty
- CachedMap metadata raises when out-of-date
- Encoding unencodable text as Code128 breaks label preview
- Identifier between range breaks filter when blank params passed
- DwcIndex failing to update on Georeference, Role, BiocurationClassification, TaxonName, InternalAttribute changes
- Sometimes URL parameters are set incorrectly in facets.
- A COLDP export name and taxon remarks bug [#3837]
- Project dump not working when all params were supplied [#3967]
- Radial annotator: Selected object in "Move to" section is not displayed in Depictions slice
- Project SQL export failed to export tables with NULL project_id.
- Spatial Summary of the results in Filter Collecting Event "URI too large error" [#3937]

### Changed

- Upgraded to Rails 7. [#3819]
- Changed default URL protocol to HTTPS for TaxonWorks-generated e-mails in production environments
- Added bootsnap gem to speed up boot times. `tmp/cache` dir is used as cache by this gem
- Removed `versions_associations` and `shortened_urls` tables from Project SQL export
- Replace validations modal in Browse nomenclature task [#3974]
- Updated Ruby gems
- Georeference `error_radius` rounded to nearest meter before save [#3946]

[#2029]: https://github.com/SpeciesFileGroup/taxonworks/issues/2029
[#3800]: https://github.com/SpeciesFileGroup/taxonworks/issues/3800
[#3819]: https://github.com/SpeciesFileGroup/taxonworks/pull/3819/
[#3837]: https://github.com/SpeciesFileGroup/taxonworks/pull/3837/
[#3936]: https://github.com/SpeciesFileGroup/taxonworks/issues/3936
[#3937]: https://github.com/SpeciesFileGroup/taxonworks/issues/3937
[#3946]: https://github.com/SpeciesFileGroup/taxonworks/issues/3946
[#3947]: https://github.com/SpeciesFileGroup/taxonworks/pull/3947/
[#3949]: https://github.com/SpeciesFileGroup/taxonworks/issues/3949
[#3961]: https://github.com/SpeciesFileGroup/taxonworks/issues/3961
[#3967]: https://github.com/SpeciesFileGroup/taxonworks/pull/3967
[#3969]: https://github.com/SpeciesFileGroup/taxonworks/pull/3969
[#3974]: https://github.com/SpeciesFileGroup/taxonworks/pull/3974

## [0.41.1] - 2024-05-10

### Added

- An extended biological associations API endpoint [#3944]
- Updated Ruby gems.

### Fixed

- Empty `higherClassification` included ""
- Resaving Image resets height/width and original filename
- New image from Data raising from path error
- Filters: JSON request URL overflows container when too long
- PDF Button is missing in Filter Sources
- DwC Import task: Replace dialog shows `undefined` instead the current value
- Radial annotator: Data attributes can't be deleted from the list
- Radial quick forms: Collecting event slice doesn't render correctly
- CSD: In some cases, the locking mechanism does not work correctly [#3941]

[#3941]: https://github.com/SpeciesFileGroup/taxonworks/issues/3941
[#3944]: https://github.com/SpeciesFileGroup/taxonworks/issues/3944

## [0.41.0] - 2024-05-02

### Added

- Filter nomenclature: Local and global identifiers facets [#3942]
- Field synchronizer task- batch edit (regex too), update and synchronize columns and between columns
- `misspelling` option to API `taxon_name_relationship_set[]`

### Changed

- Gemfile update
- Improvements(?) to Collecting Event level classifier [#3821]

### Fixed

- Asynchronous batch updates on individual objects
- Invisible edges in biological associations graph viz
- PDF button is available for all document types [#3933]

[#3821]: https://github.com/SpeciesFileGroup/taxonworks/issues/3821
[#3933]: https://github.com/SpeciesFileGroup/taxonworks/issues/3833
[#3942]: https://github.com/SpeciesFileGroup/taxonworks/issues/3942

## [0.40.6] - 2024-04-30

### Changed

- Updated Ruby gems

### Fixed

- Notes params not applied in Source filters (anywhere) [#3927]
- OTU autocomplete raises when no taxon names match
- Moving from Source to Image filter failed to return cited images
- CSD: Catalog number panel displays warning messages when the namespace is set

[#3927]: https://github.com/SpeciesFileGroup/taxonworks/issues/3927

## [0.40.5] - 2024-04-25

### Added

- `/api/v1/taxon_name_relationships.csv` endpoint

### Changed

- Dwca `otu_name` only includes Otu#name, never anything else.
- `api/v1/otus/autocomplete` now more acurately returns the label of the matching term, i.e. Combinations are supported in rendering [https://github.com/SpeciesFileGroup/taxonpages/issues/193]
- Update Ruby gems

### Fixed

- Taxon name with nomen nudum status, nomen dubium status + invalidating relationship should be treated as separate invalid taxon.
- Quick forms: Lock buttons don't work on Biological associations.
- Week in review task [#3926]
- Missing Image metadata breaks radial
- Basic endemism task had a broken link out
- Prevent raise on bad polygon (LinearRing) Georeferences

[#3926]: https://github.com/SpeciesFileGroup/taxonworks/issues/3926

## [0.40.4] - 2024-04-21

### Added

- User estimated time tracking at the per-project level
- Orphaned DwcOccurrence and DelayedJob job metadata to admin Health report

### Changed

- Unified some methods on dwca export, refactored for speedups and memory
- Updated Ruby gems

### Fixed

- Dwca error from missmatched ids leading to bad sorts
- Manage controlled vocabulary task: New button resets type [#3923]
- Resource is spelled recource [#3922]

[#3922]: https://github.com/SpeciesFileGroup/taxonworks/issues/3922
[#3923]: https://github.com/SpeciesFileGroup/taxonworks/issues/3923

## [0.40.3] - 2024-04-14

### Changed

- Browse OTU: Replace descendants endpoint for the same used on TaxonPages. Now this panel is available for all ranks
- Bundle/gem update

### Fixed

- 2 issues with taxon names autocomplete (internal and api/v1)
- Memoization in dwca export

## [0.40.2] - 2024-04-09

### Added

- "Venn" factets to filter- logical operations on filter results [#3908]
- Sort column on project vocabulary task [#3915]

### Fixed

- `/data_attributes/brief` not scoped to project
- New collecting event: It tries to save the label even if it is empty
- Spatial summary return to filter with empty cached level fields [#3907]
- Comprehensive form: Sometimes Attributes are not cleaned when new collection object is created [#3910]
- DwC importer crashing when uploading files with CSV extension.
- DwC importer not honouring field and string delimiters when processing headers
- DwC importing wrongly allowing unreadable files to be staged

### Changed

- Updated Ruby gems.

[#3908]: https://github.com/SpeciesFileGroup/taxonworks/issues/3908
[#3907]: https://github.com/SpeciesFileGroup/taxonworks/issues/3907
[#3910]: https://github.com/SpeciesFileGroup/taxonworks/issues/3910
[#3915]: https://github.com/SpeciesFileGroup/taxonworks/issues/3915

## [0.40.1] - 2024-04-02

### Added

- Some more quality-of-life changes to Leads/keys
- Spatial summary report for CollectingEvent filter
- Geographic Area radial navigator links to associated filters
- Radial nomenclature: verbatim_author slice [#3896]

### Changed

- Gems updated

### Fixed

- Async batch update calls on individual objects failing [#3905]
- DwC export without CollectingEvents failing [#3897]
- Cloning CollectingEvents sets creator to the person who cloned the record
- Filter Staged Images missing filter button [#3901]

[#3905]: https://github.com/SpeciesFileGroup/taxonworks/issues/3905
[#3897]: https://github.com/SpeciesFileGroup/taxonworks/issues/3897
[#3896]: https://github.com/SpeciesFileGroup/taxonworks/issues/3896
[#3901]: https://github.com/SpeciesFileGroup/taxonworks/issues/3901

## [0.40.0] - 2024-03-26

_Special thanks to Tom Klein for his amazing open-source contributions on this release!._

### Added

- Model FieldOccurrence (observations sensu iNaturalist), with corresponding "new" task [#1643]
- Model "Lead" (dichotomous key support), with corresponding "new" task" [#1691]
- Key hub task [#3881]
- New OTU task
- "Week in review" task, visualize records added and navigate to them in filter context
- OTU name to Filter CO result [#3861]
- Batch add/remove sources to project from Source filter [#3888]
- Add taxon name autocomplete to Type specimen facet
- DwC Dashboard: Use the same DwC download of collection object filter task
- DwC-A Workbench: Add pagination for created imports
- Clone mode on image matrix
- Radial CO: Add preparation type slice [#3889]
- Radial mass navigation [#3672]
- Batch update or add data attributes [#3748]
- Include OTU `name` in Filter Collection Objects result
- Text file delimiter options to DwC import [#3894]
- CSV format for DwC importer
- Project vocabulary word-cloud text links to filter result for some models (e.g. CollectingEvent)

### Changed

- Images can no longer be duplicated attempting and are seemlessly normalized at creation [#2909]
- Filter images: Remove quick forms for Depictions [#3869]
- New image task: Add alert when trying to restart the interface without applying changes
- New CE: Destroy label when print label input is empty [#3878]
- Updated Ruby gems
- DwC importer now defaults to use `"` as string delimiter when importing and downloading tables.

### Fixed

- Project vocabulary handling of numeric fields
- Rediculous number of identifiers preventing collecting event editing [#3715]
- Community-based models not showing AlternateValues [#3883]
- Browse OTUs: headers do not link to correct panel [#3868]
- DwC-A importer crashing on hybrid formula scientific names
- Crash when georeferencing with zero meters of uncertainty
- New CE: Custom attributes don't refresh on new/edit CE [#3874]
- Radial quick forms: Asserted distribution screen partially blocked by a white rectangle [#3891]
- Print label task doesn't apply styles to labels [#3776]
- Missing collection object links on map markers

[#3748]: https://github.com/SpeciesFileGroup/taxonworks/issues/3748
[#3881]: https://github.com/SpeciesFileGroup/taxonworks/issues/3881
[#2909]: https://github.com/SpeciesFileGroup/taxonworks/issues/2909
[#1643]: https://github.com/SpeciesFileGroup/taxonworks/issues/1643
[#1691]: https://github.com/SpeciesFileGroup/taxonworks/issues/1691
[#3672]: https://github.com/SpeciesFileGroup/taxonworks/issues/3672
[#3715]: https://github.com/SpeciesFileGroup/taxonworks/issues/3715
[#3776]: https://github.com/SpeciesFileGroup/taxonworks/issues/3776
[#3861]: https://github.com/SpeciesFileGroup/taxonworks/issues/3861
[#3868]: https://github.com/SpeciesFileGroup/taxonworks/issues/3868
[#3869]: https://github.com/SpeciesFileGroup/taxonworks/issues/3869
[#3878]: https://github.com/SpeciesFileGroup/taxonworks/issues/3878
[#3883]: https://github.com/SpeciesFileGroup/taxonworks/issues/3883
[#3888]: https://github.com/SpeciesFileGroup/taxonworks/issues/3888
[#3889]: https://github.com/SpeciesFileGroup/taxonworks/issues/3889
[#3891]: https://github.com/SpeciesFileGroup/taxonworks/issues/3891
[#3894]: https://github.com/SpeciesFileGroup/taxonworks/issues/3894

## [0.39.0] - 2024-03-01

### Added

- Project vocabulary task [#864]
- Global identifier classes for Web of Science and Zoological Record [#3853]
- `/api/v1/biological_associations/simple.csv` endpoint
- Return a png of any image via `/api/v1/images/:id/scale_to_box(/:x/:y/:width/:height/:box_width/:box_height)` [#3852]
- `content_type` and `original_png` attributes to `/api/v1//images/123` [#3852]
- Ability to extend housekeeping on some filters to check changes on related models [#3851]
- Some new soft validations on Misspellings

### Fixed

- Handle bad BibTeX coming back from CrossRef.
- Quick Forms: Observation matrices slice doesn't work
- Quick Forms: Content slice doesn't display contents [#3850]
- Browse OTU: Load preferences
- New loan task: reset button doesn't work [#3856]
- New image task doesn't create citations without attributions
- Missing pagination headers for 4 endpoints [#3859]

### Changed

- Allow omitting seconds in non-interval ISO-8601 date times in DwC importer.

[#864]: https://github.com/SpeciesFileGroup/taxonworks/issues/864
[#3853]: https://github.com/SpeciesFileGroup/taxonworks/issues/3853
[#3851]: https://github.com/SpeciesFileGroup/taxonworks/issues/3851
[#3852]: https://github.com/SpeciesFileGroup/taxonworks/issues/3852
[#3850]: https://github.com/SpeciesFileGroup/taxonworks/issues/3850
[#3856]: https://github.com/SpeciesFileGroup/taxonworks/issues/3856
[#3859]: https://github.com/SpeciesFileGroup/taxonworks/issues/3859

## [0.38.3] - 2024-02-25

### Added

- `/api/v1/common_names` [#3794]
- `/api/v1/biological_associations/simple` A simple table format for BiologicalAssociations
- Housekeeping facet in filters has "Recent" button with options to populate past date ranges
- Radials to New image task

### Fixed

- DwC download not scoping DataAttributes correctly when records are a subset of objecs from a CollectingEvent
- DwC Dashboard buttons scoped to recent timeframes [#3774]
- A couple .csv endpoints for /api/v1
- Radial annotator: Filter tab doesn't work in depictions slice [#3824]
- Filters: Geographic area facet doesn't clear geographic area after reset [#3840]
- Radial collection object: Taxon determination list is not visible
- Align metadata in GeographicItem debug view
- Biological associations filter bugs
- Several radial annotator and batch annotator slice fixes
- DwC checklist importer fails quietly when `taxonomicStatus` is empty [#3783]

### Changed

- Documents are no longer destroyed when the last documentation referencing them are deleted.
- Use Ruby 3.3
- CI build/test with PostgreSQL 15
- CI base image uses Node 20

[#3783]: https://github.com/SpeciesFileGroup/taxonworks/issues/3783
[#3840]: https://github.com/SpeciesFileGroup/taxonworks/issues/3840
[#3774]: https://github.com/SpeciesFileGroup/taxonworks/issues/3774
[#3794]: https://github.com/SpeciesFileGroup/taxonworks/issues/3794
[#3824]: https://github.com/SpeciesFileGroup/taxonworks/issues/3824
[#3833]: https://github.com/SpeciesFileGroup/taxonworks/issues/3833

## [0.38.2] - 2024-02-09

### Added

- Highlight row on click in DwC Importer [#3795]
- Batch update CollectingEvent from CollectionObject filter radial
- Batch update `meta_prioritize_geographic_area` from CollectingEvent filter radial [#3498]

### Fixed

- CollectionObject summary nomenclature tag failing when no names are present
- Papertrail views for most models were failing
- Synchronized winding of polygons and multipolygons [#3712], and others
- DataAttribute alignment in DwC, take 3 [#3802]
- Radial Annotator: Citation count no longer updates [#3806]
- Radial Annotator: Depiction count no longer updates [#3813]
- Radial annotator: Attribution slice loads incorrect records
- Image matrix: OTU depictions cells are not displaying the correct images when `otu_filter` parameter is set
- New combination task freezes in some cases
- SQL project dump duplicating hierarchies tables rows causing index creation to fail on restore
- OtuPicker doesn't display OTU label when a new OTU is created in New loan task [#3809]

### Changed

- All polygons and multi_polygons in GeographicItems are wound to CCW after save
- Updated Ruby gems

[#3498]: https://github.com/SpeciesFileGroup/taxonworks/issues/3498
[#3712]: https://github.com/SpeciesFileGroup/taxonworks/issues/3712
[#3802]: https://github.com/SpeciesFileGroup/taxonworks/issues/3802
[#3795]: https://github.com/SpeciesFileGroup/taxonworks/issues/3795
[#3806]: https://github.com/SpeciesFileGroup/taxonworks/issues/3806
[#3813]: https://github.com/SpeciesFileGroup/taxonworks/pull/3813

## [0.38.1] - 2024-02-01

### Fixed

- DwC dumps cross-mapping attributes between CollectingEvent and CollectionObject (for real?) [#3802]
- Favorite cards section layout
- Radial batch triggers "re-search" when nothing is changed
- Custom attributes component loads auto filled with incorrect values [#3805]
- DwC importer crashing on real DwC-A zip archives when first table rows are not headers.

[#3802]: https://github.com/SpeciesFileGroup/taxonworks/issues/3802
[#3805]: https://github.com/SpeciesFileGroup/taxonworks/issues/3805

## [0.38.0] - 2024-01-31

### Added

- GeographicItem debug task
- `documentation_object_type` and `documentation_object_id` to documentation filter

### Changed

- Use `zeitwerk` loading framework [#2718]

### Fixed

- DwC dumps cross-mapping attributes between CollectingEvent and CollectionObject [#3802]
- Staged Image filter failing on some identifier queries
- TaxonName batch update
- Contributing link [#3752]
- Uncaught promise errors [#3767]
- Custom attributes triggers `isUpdated` ce state [#3764]
- Custom attributes panels don't check if data attributes already exist [#3762]
- Gender agreement of misspellings [#3782]
- Loan item list doesn't update when adding a loan item from Tag or Pinboard [#3784]
- Unable to add a CO loan item to a loan that already has an OTU loan item with the same id [#3785]
- CO Loan gifts have tag "On Loan until false" [#3731]
- Figure panel in New content task
- DwC Occurrence Importer using out of project scope http://rs.tdwg.org/dwc/terms/FossilSpecimen biocuration class.
- Hub: Status filter doesn't work correctly [#3791]
- Hub: Left and right arrow keys on task hub don't work as expected. [#3792]

[#3802]: https://github.com/SpeciesFileGroup/taxonworks/issues/3802
[#2718]: https://github.com/SpeciesFileGroup/taxonworks/issues/2718
[#3731]: https://github.com/SpeciesFileGroup/taxonworks/issues/3731
[#3752]: https://github.com/SpeciesFileGroup/taxonworks/issues/3752
[#3762]: https://github.com/SpeciesFileGroup/taxonworks/issues/3762
[#3764]: https://github.com/SpeciesFileGroup/taxonworks/issues/3764
[#3767]: https://github.com/SpeciesFileGroup/taxonworks/issues/3767
[#3784]: https://github.com/SpeciesFileGroup/taxonworks/issues/3784
[#3785]: https://github.com/SpeciesFileGroup/taxonworks/issues/3785
[#3791]: https://github.com/SpeciesFileGroup/taxonworks/issues/3791
[#3792]: https://github.com/SpeciesFileGroup/taxonworks/issues/3792

## [0.37.1] - 2024-01-04

### Added

- `Emendavit` status for ICN names [#3716]
- "CONFIRM" screen when editing a collecting event with > 100 attached COs [#3727]
- `epithet_only` parameter and facet to taxon name filter [#3589]
- Links for users profiles on project members list (only for administrators)
- Cursor and text to reveal project preference predicates can be reordered [#3736]
- Batch append collectors to Collecting Events within CE filter
- Batch set Collecting Event date and time within CE filter
- Darwin Core `superfamily`, `subfamily`, `tribe`, `subtribe` export support
- Darwin Core exporter: include Notes from most recent `TaxonDetermination` as `identificationRemarks`
- Save user's custom layout tables [#3756] [#3307] [#3568]

### Changed

- DwC Occurrence Importer: Parse authorship information in typeStatus field
- DwC Exporter: `recordedBy` and `identifiedBy` fields use `First Prefix Last Suffix` order
- Project member list now has links for users profiles (only for administrators)

### Fixed

- `dwc_occurrence_id` param to `/api/v1/dwc_occurrences`
- Another `project_id` scope issue in Otu Filter
- Update DwcOccurence index endpoint
- Uniquify people: Always show radials for selected person
- Remove property doesn't work on Biological relationship composer
- Feet to meter conversion does not work as expected [#2110]
- OTUs autocomplete API endpoint ignoring `having_taxon_name_only` param
- DwC importer creating multiple namespaces instead of just one for `occurrenceID` and `eventID`
- Combination always visible [#3366]
- Copy text from PDF

[#2110]: https://github.com/SpeciesFileGroup/taxonworks/issues/2110
[#3307]: https://github.com/SpeciesFileGroup/taxonworks/issues/3307
[#3366]: https://github.com/SpeciesFileGroup/taxonworks/issues/3366
[#3568]: https://github.com/SpeciesFileGroup/taxonworks/issues/3568
[#3589]: https://github.com/SpeciesFileGroup/taxonworks/issues/3589
[#3716]: https://github.com/SpeciesFileGroup/taxonworks/issues/3716
[#3727]: https://github.com/SpeciesFileGroup/taxonworks/issues/3727
[#3736]: https://github.com/SpeciesFileGroup/taxonworks/issues/3736
[#3756]: https://github.com/SpeciesFileGroup/taxonworks/issues/3756

## [0.37.0] - 2023-12-14

### Added

- DwC `verbatimLabel` support [#2749]
- Preview option and results reports for filter based batch updates [#3690]
- Freeform digitization, draw shapes to stub CollectionObjects [#3113]
- `superfamily`, `tribe` and `subtribe` DwC terms now supported in occurrences importer [#3705]

### Changed

- Improved simplified taxonomy rendering
- Unifies all filter-originating batch updates to a common look and feel [#3690]
- Report file size to browser for downloads
- DwC Checklist Importer: blank `originalNameUsageID` skip original combination creation instead of erroring [#3680]

### Fixed

- Ordering of descriptors in TNT format [#3711]
- Some ObservationMatrix views/formats were broken or unavailable for preview
- DwC-A checklist importer: fix importer crash caused by nil parent
- Address rendering on loan form [#3645]
- Citation topic whitespace for paper catalog [#187]
- Source filter with duplicate results when coming from another filter [#3696]
- `ancestrify` parameter for Otu queries not scoping to TaxonNames correctly
- Filter source: BibTeX type facet
- Project data SQL export obfuscating all users instead of just non-members
- Project data SQL export outputting only two rows per hierarchy-related tables
- AssertedDistributions API index call failed when OTU not linked to taxon name
- Missing valid names in nomenclature match task
- DwC Occurrence Importer: prefer correct protonym spelling when misspelling matches current conjugation

[#187]: https://github.com/SpeciesFileGroup/taxonpages/issues/187
[#2749]: https://github.com/SpeciesFileGroup/taxonworks/issues/2749
[#3113]: https://github.com/SpeciesFileGroup/taxonworks/issues/3113
[#3645]: https://github.com/SpeciesFileGroup/taxonworks/issues/3645
[#3680]: https://github.com/SpeciesFileGroup/taxonworks/issues/3680
[#3690]: https://github.com/SpeciesFileGroup/taxonworks/issues/3690
[#3696]: https://github.com/SpeciesFileGroup/taxonworks/issues/3696

## [0.36.0] - 2023-11-30

### Added

- Staged image CollectionObjects are destroy if a) stubs and b) depictions are removed from them to another CollectionObject [#3172]
- `/api/v1/biological_associations/123/globi` (preview experiment)
- `/api/v1/biological_associations/123/resource_relationship` (preview experiment)
- BiologicalAssociations as raw TaxonWorks data`/api/v1/biological_associations.csv`
- BiologicalRelationships as raw TaxonWorks data`/api/v1/biological_relationships.csv`
- DwC ResourceRelationship extension (preview) [#2554]
- Taxonomy summary to CollectionObject summary report
- Metadata summary report from Filter BiologicalAssociations
- Biological associations simple table preview, sortable columns [#1946]
- GLOBI format table from Filter BiologicalAssociations (preliminary)
- Family by genera report from Filter BiologicalAssociations
- DwC ResourceRelationship extension preview from Filter BiologicalAssociations
- Visualize network from Filter BiologicalAssociations
- BiologicalRelationship can have Identifiers
- "ancestrify" option to TaxonName and Otu filters (adds ancestors of filter result)
- Auto UUIDs as new Identifier::Global::Uuid::Auto for models
- Auto UUIDs are created for BiologicalAssociations and OTUs
- Maintenance Task to add UUIDs to objects that can have them but don't
- TaxonName model to customize attributes
- TaxonNameRelationship model, added validation for the rank of type species and type genus.
- New source task: Person source
- Index view to API for /depictions
- Added extend[]=role_counts to /person/123.json
- Batch update OTU taxon_name within OTU filter [#3656]
- DwC Checklist importer: support "invalid", "incorrectOriginalSpelling" taxonomic Status
- DwC Checklist importer: option to match and update existing names rather than create new hierarchy from Root
- DwC Occurrence importer: search for repository URL

### Changed

- CachedMaps of ancestors are set for rebuild when a descendant Georeference or AssertedDistribution is created
- Radial annotator: Move selected source to the bottom in citation form [#3652]
- DwC Occurrence importer: more helpful protonym, institution error messages
- Filter interfaces: remove items from list instead redirect to data view [#3659]
- New BiologicalAssociation defaults to task, not old form
- Extracted CSV generating code to lib/export/csv

### Fixed

- Buttons to remove BiologicalProperties in composer failing [#3673]
- Could not destroy BiologicalRelationship if properties attached
- Some CollectionObject summary values were not scoped to filter query
- Filtering People returned duplicate values one name string searches
- BiologicalAssociations passed to TaxonNames missed object names
- Nulified cached values in Collecting Event, if Geographic area deleted [#3668]
- Match TaxonName based on original combination [#3365]
- Radial AD: Quick/recent selector broken on "Move". [#3640]
- New taxon name: Author panel overflow when source has a long link
- Edit Loan: Loans created without recipient or supervisor cannot be updated
- Fixed bug in DwC importer background processor that was not dealing with errored records.
- Browse OTU: autocomplete overflow [#3667]
- Comprehensive: Relationship doesn't show up on biological associations list [#3671]
- DwC Occurrence importer: protonyms could not be found if authorship information didn't match
- DwC Occurrence importer: protonyms could not be found if author was Person [#3677]
- DwC Checklist importer: empty `scientificNameAuthorship` field would cause row to error [#3660]
- DwC Checklist importer: subsequent combinations with synonym status whose parents are synonyms would cause row to error
- Could not set Repository Index Herbariorum flag in interface
- Uniquify People: autocomplete would not select people for merging if already present in Match people table

[#3172]: https://github.com/SpeciesFileGroup/taxonworks/issues/3172
[#1946]: https://github.com/SpeciesFileGroup/taxonworks/issues/1946
[#2554]: https://github.com/SpeciesFileGroup/taxonworks/issues/2554
[#3365]: https://github.com/SpeciesFileGroup/taxonworks/issues/3365
[#3640]: https://github.com/SpeciesFileGroup/taxonworks/issues/3640
[#3652]: https://github.com/SpeciesFileGroup/taxonworks/issues/3652
[#3656]: https://github.com/SpeciesFileGroup/taxonworks/issues/3656
[#3659]: https://github.com/SpeciesFileGroup/taxonworks/issues/3659
[#3660]: https://github.com/SpeciesFileGroup/taxonworks/issues/3660
[#3667]: https://github.com/SpeciesFileGroup/taxonworks/issues/3667
[#3668]: https://github.com/SpeciesFileGroup/taxonworks/issues/3668
[#3671]: https://github.com/SpeciesFileGroup/taxonworks/issues/3671
[#3673]: https://github.com/SpeciesFileGroup/taxonworks/issues/3673
[#3677]: https://github.com/SpeciesFileGroup/taxonworks/issues/3677

## [0.35.3] - 2023-11-13

### Added

- Radial collection object: Add repository [#3637]

### Changed

- CachedMaps (WebLevel1) is now based on "State" shapes only, improving resolution
- CachedMap build process adds pre-build step to greatly minimize overall number of spatial calculations
- CachedMap spatial calculations use a intersection + "smoothing" approach
- Also use year of publication to determine correct protonyn having homonyms [#3630]
- Improved error message when `typeStatus` name is a homonym in DwC occurrences importer [#3632]

### Fixed

- Duplicate loans appearing Loan filter [#3636]
- New source when cloned and saved is not added to the project sources [#3629]
- Sequence display when not a Primer
- CachedMap indexing speedups failed to properly utilize prior work
- Duplicate CachedMapRegister rows being created per object
- New Image task, second "Apply" button is not working #3628
- ' [sic]' not removed when searching for synonyms in database to compare with `typeStatus` in DwC occurrence importer [#3633]

[#3628]: https://github.com/SpeciesFileGroup/taxonworks/issues/3636
[#3628]: https://github.com/SpeciesFileGroup/taxonworks/issues/3628
[#3629]: https://github.com/SpeciesFileGroup/taxonworks/issues/3629
[#3630]: https://github.com/SpeciesFileGroup/taxonworks/pull/3630
[#3632]: https://github.com/SpeciesFileGroup/taxonworks/pull/3632
[#3633]: https://github.com/SpeciesFileGroup/taxonworks/pull/3633
[#3637]: https://github.com/SpeciesFileGroup/taxonworks/pull/3637

## [0.35.2] - 2023-11-07

### Changed

- Update Gemfiles
- CachedMap algorithm, now far more precise.
- Browse OTU: Image gallery section is now available for all ranks [#3612]
- Map saves tile preferences [#3619]

### Fixed

- Anyone can destroy a Community (Global) identifier on a Community object [#3601]
- Newfoundland/CAR mapping issue [#3588]
- Role callbacks interfered with creation of nested objects [#3622] !! Potentially breaking fix !!
- Queries to `/api/v1/sources` not scoping to project when `project_token` used [#3623]
- CollectionObject summary report tab clicks
- Cached map preview incorrect/default GeographicItem id for GeographicAreas
- Collection object summary report bad link
- Task Biological associations graph: Save fails when trying to update a graph
- Role picker doesn't show organization name when created [#3611]
- Spinner hangs when apply fails in New Images task [#3620]

[#3601]: https://github.com/SpeciesFileGroup/taxonworks/issues/3601
[#3588]: https://github.com/SpeciesFileGroup/taxonworks/issues/3588
[#3622]: https://github.com/SpeciesFileGroup/taxonworks/issues/3622
[#3623]: https://github.com/SpeciesFileGroup/taxonworks/issues/3623
[#3611]: https://github.com/SpeciesFileGroup/taxonworks/issues/3611
[#3612]: https://github.com/SpeciesFileGroup/taxonworks/issues/3612
[#3619]: https://github.com/SpeciesFileGroup/taxonworks/issues/3619
[#3620]: https://github.com/SpeciesFileGroup/taxonworks/issues/3620

## [0.35.1] - 2023-10-23

### Changed

- Doubled the number of favoritable tasks to 40 [#3600]
- Add record frame to Filter Source [#3615]

### Fixed

- TaxonPage stats, maybe, who knows at this point.
- Images for OTU type material expanded to all protonyms
- Reset project preferences [#3599]
- Project TSV dump permissions on server side
- Clone moved CVT, not cloned project

[#3600]: https://github.com/SpeciesFileGroup/taxonworks/issues/3600
[#3599]: https://github.com/SpeciesFileGroup/taxonworks/issues/3599
[#3615]: https://github.com/SpeciesFileGroup/taxonworks/issues/3615

## [0.35.0] - 2023-10-19

### Added

- Outdated names task for CollectionObjects (compare to COL) [#2585]
- Unified project data download task [#1009], in part
- Download project as zipped TSV tables in Download [#1009]
- CSV generating endpoints `/api/v1/taxon_names.csv` and `/api/v1/otus.csv`
- Filter CollectionObject links to "Collection Summary" task [#3434]
- CollectionObject type facet
- Coordinate and collecting event sections in Browse OTUs

### Changed

- Download routes now name files as `.tsv`
- CollectingEvent allowable max records made smart [#3590]
- Added `extend[]=attribution` to `/images/123.json`

### Fixed

- TaxonNameClassification download
- TaxonName `descendants` facet always included self, it shouldn't have
- Without document facet
- Object cloning in OriginRelationship caused infinite loops [#3594]
- Quote handling in API autocomplete calls
- Organization name not displaying in attribution copyright _label_
- Manage Controlled vocabulary term: CVT list is not reloading after clone them from other project
- Not possible to delete asserted distribution once added in radial object [#3591]
- Manage controlled vocabulary: Delete button doesn't work [#3593]

[#2585]: https://github.com/SpeciesFileGroup/taxonworks/issues/2585
[#1009]: https://github.com/SpeciesFileGroup/taxonworks/issues/1009
[#3593]: https://github.com/SpeciesFileGroup/taxonworks/issues/3593
[#3594]: https://github.com/SpeciesFileGroup/taxonworks/issues/3594
[#3590]: https://github.com/SpeciesFileGroup/taxonworks/issues/3590
[#3434]: https://github.com/SpeciesFileGroup/taxonworks/issues/3434
[#3591]: https://github.com/SpeciesFileGroup/taxonworks/issues/3591

## [0.34.6] - 2023-10-06

### Added

- WKT and GeoJSON endpoints for /geographic_items/123.wkt
- Clone ControlledVocabularies across projects [#3562]
- Batch move taxon names to a new parent within TaxonName filter [#3584]
- Batch update Source with a Serial within Source filter [#3561]
- Browse nomenclature hierachy nav counts of invalid/valid link to filter
- Reset forms for user preferences and project card favorites [#3545]
- Otu RCC5 relationships to the COLDP exporter [#3569]
- Filter images slice in radial linker [#3574]
- Name relations to Catalogue of Life data package exports [#1211]
- Type Materials to Catalogue of Life data package exports [#3213]
- Filter list: Add border to highlight the last row where a radial was opened [#3583]

### Changed

- Update Gemfile
- TaxonName stats metadata includes coordinate OTUs and synonyms of self
- Change map position in Filter collecting events [#3571]
- Add type material button is now blue [#3579]
- Radial navigator: close radial menu when slices are opened in a new tab/window clicking and pressing ctrl/shift/meta keys [#3582]

### Fixed

- Loans referencing containers have 'Total' properly calculated [#3035]
- TaxonDetermination sort order on CollectionObject comprehensive/browse... again [#1355]
- OTU API autocomplete not resolving to valid OTU
- Attribution rendering had cryptic license value [#3577]
- GeographicAreas not registering for some DWCA imports [#3575]
- New collecting event: georeference from verbatim button creates two identical georeferences [#3573]

[#3035]: https://github.com/SpeciesFileGroup/taxonworks/issues/3035
[#1355]: https://github.com/SpeciesFileGroup/taxonworks/issues/1355
[#3562]: https://github.com/SpeciesFileGroup/taxonworks/issues/3562
[#3584]: https://github.com/SpeciesFileGroup/taxonworks/issues/3584
[#3561]: https://github.com/SpeciesFileGroup/taxonworks/issues/3561
[#3545]: https://github.com/SpeciesFileGroup/taxonworks/issues/3545
[#3571]: https://github.com/SpeciesFileGroup/taxonworks/issues/3571
[#3573]: https://github.com/SpeciesFileGroup/taxonworks/issues/3573
[#3574]: https://github.com/SpeciesFileGroup/taxonworks/issues/3574
[#3577]: https://github.com/SpeciesFileGroup/taxonworks/issues/3577
[#3579]: https://github.com/SpeciesFileGroup/taxonworks/issues/3579
[#3582]: https://github.com/SpeciesFileGroup/taxonworks/issues/3582
[#3583]: https://github.com/SpeciesFileGroup/taxonworks/issues/3583

## [0.34.5] - 2023-09-26

### Added

- Cached map item report (linked from Filter OTUs)
- Depictions list on Filter image

### Changed

- Calls to `/api/v1` have a new key/value signature
- Staged image metadata field format from JSON to JSONB [#3446]
- Updated Ruby gems

### Fixed

- Batch import BibTeX failing on empty entries
- Chronology stats report
- ImportAttribute facet not working on any predicate searches
- Taxon name/otus filter order bug
- Staged image queries failing when multiple facets used [#3556]
- Citations list is truncated in Radial Annotator [#3560]
- DwC attributes are now showing in Stepwise determinations task
- Quick taxon name only works for species [#3554]
- Filter Images: Change `per` doesn't update the table [#3566]

[#3554]: https://github.com/SpeciesFileGroup/taxonworks/issues/3554
[#3556]: https://github.com/SpeciesFileGroup/taxonworks/issues/3556
[#3560]: https://github.com/SpeciesFileGroup/taxonworks/issues/3560
[#3566]: https://github.com/SpeciesFileGroup/taxonworks/issues/3566

## [0.34.4] - 2023-09-15

### Added

- ImportAttribute facets to various filters
- Project data curation issue tracking URL field (and to base API response) [#3550]
- Manual option to regenerate derivative images on Show Image
- API gallery endpoint `/depictions/gallery`
- Image quick forms, add depictions in the context of an image [#3540]
- Tables of data to nomenclature stats plots, with option to copy to clipboard
- With/out nomenclature date facet on filter nomenclature
- Determiners can be re-ordered (topmost, regardless of year, is preferred) [#1355]

### Changed

- Updated Gemfile
- Updated JS packages
- Derivative images strip EXIF and auto orient
- TaxonName autocomplete change to a strict match mode.
- Bold geographic levels in Type specimen panel in Browse OTU [#3544]

### Fixed

- Subqueries in unified filters were silently ignoring components of the query, e.g. fix spatial + subquery requests [#3552]
- Geographic level names not displaying on Browse OTU [#3553]
- Sqed images that fail processing will try again with slower method automatically [#3070] [#3443]
- TaxonName dynamic observation matrix row not properly scoped [#3454]
- OTU API autocomplete fails to sort results
- Duplicate type status per CollectionObject are not allowed [#3535]
- Edit/New taxon name: Author order for taxon name does not match author order of source [#3551]
- Some issues with order of roles (e.g. Determinations) in display [#1355]

[#1355]: https://github.com/SpeciesFileGroup/taxonworks/issues/1355
[#3443]: https://github.com/SpeciesFileGroup/taxonworks/issues/3443
[#3552]: https://github.com/SpeciesFileGroup/taxonworks/issues/3552
[#3553]: https://github.com/SpeciesFileGroup/taxonworks/issues/3553
[#3550]: https://github.com/SpeciesFileGroup/taxonworks/issues/3550
[#3070]: https://github.com/SpeciesFileGroup/taxonworks/issues/3070
[#3454]: https://github.com/SpeciesFileGroup/taxonworks/issues/3454
[#3535]: https://github.com/SpeciesFileGroup/taxonworks/issues/3535
[#3540]: https://github.com/SpeciesFileGroup/taxonworks/issues/3540
[#3544]: https://github.com/SpeciesFileGroup/taxonworks/issues/3544
[#3551]: https://github.com/SpeciesFileGroup/taxonworks/issues/3551

## [0.34.3] - 2023-09-05

### Added

- Task - Nomenclature by year plots [#2472]
- API for BiologicalRelationships -`api/v1/biological_relationships?extend[]=biological_property` [#3525]
- Organization to Attribution slice in Radial annotator [#3529]
- Delayed job queue `cached`, currently used in Role-related updates [#3437]
- Allow organization determiners in DwC occurrences importer

### Changed

- Error radius also captured as literal value in addition to conversion to error polygon [#3471]
- Batch update of collecting event geographic areas is now run in the background, limited to 250 record [#3527]
- Reverted index-based TaxonName autocomplete to comprehensive version
- Upgraded docker env to Postgis 3.4

### Fixed

- Missing synonym record for basionym in COLDP export [#3482]
- Fixed loan related links in several places [#3463]
- Common name language ISO when no language [#3530]
- Attribution displays owner/copyright holder Organization names [#3515]
- CollectingEvent filter fails on cached*geo*\* fields [#3526]
- Reviewing and Organization's related data
- CollectionObject timeline didn't show loans when object containerized [#3528]
- Browse Annotations "On" filter doesn't work [#3505]
- Georeferences are not cleaned after unset current collecting event in comprehensive specimen digitization task [#3533]
- Fix collection object pagination in Browse OTU

[#2472]: https://github.com/SpeciesFileGroup/taxonworks/issues/2472
[#3437]: https://github.com/SpeciesFileGroup/taxonworks/issues/3437
[#3471]: https://github.com/SpeciesFileGroup/taxonworks/issues/3471
[#3463]: https://github.com/SpeciesFileGroup/taxonworks/issues/3463
[#3527]: https://github.com/SpeciesFileGroup/taxonworks/issues/3527
[#3505]: https://github.com/SpeciesFileGroup/taxonworks/issues/3505
[#3515]: https://github.com/SpeciesFileGroup/taxonworks/issues/3515
[#3525]: https://github.com/SpeciesFileGroup/taxonworks/issues/3525
[#3526]: https://github.com/SpeciesFileGroup/taxonworks/issues/3526
[#3528]: https://github.com/SpeciesFileGroup/taxonworks/issues/3528
[#3529]: https://github.com/SpeciesFileGroup/taxonworks/issues/3529
[#3530]: https://github.com/SpeciesFileGroup/taxonworks/issues/3530
[#3533]: https://github.com/SpeciesFileGroup/taxonworks/issues/3533

## [0.34.2] - 2023-08-16

### Added

- Subsequent Name Form section in New taxon name [#3460]
- Original form section in New taxon name

### Changed

- New species name button is now always visible in Type section on New taxon name task
- Improve COLDP export delimiter usability [#3522]
- Updated Node packages and Ruby gems

### Fixed

- Role scoping broken, affecting things like Verifiers list [#3514]
- `api/v1/citation` failing on last page of results [#3524]
- Fix generation of Unit tray labels from Filter nomenclature
- Object graph view failing to render (controller object no longer available!?)
- People as sources missing missing relationship (broke object graph)
- Combinations in COLDP exports lack rank [#3516]
- Fix coldp.rb undefined method `iso8601` for nil:NilClass [#3512]
- Improve TaxonName autocomplete result prioritization [#3509]
- Clone button is not clearing input after cloning

[#3514]: https://github.com/SpeciesFileGroup/taxonworks/issues/3514
[#3524]: https://github.com/SpeciesFileGroup/taxonworks/issues/3524
[#3512]: https://github.com/SpeciesFileGroup/taxonworks/issues/3512
[#3516]: https://github.com/SpeciesFileGroup/taxonworks/issues/3516
[#3509]: https://github.com/SpeciesFileGroup/taxonworks/issues/3509
[#3460]: https://github.com/SpeciesFileGroup/taxonworks/issues/3460

## [0.34.1] - 2023-08-07

### Fixed

- No parent Otu returned for TaxonName with more than 1 OTU [#3414]
- Missing organization tab in Owner panel on New image task
- BibTeX download shows incorrect results on New source task [#3510]
- Asserted distribution API endpoint crashing when count is above 50

[#3510]: https://github.com/SpeciesFileGroup/taxonworks/issues/3510

## [0.34.0] - 2023-08-04

### Added

- `api/v1/data_attributes/brief` endpoint
- `api/v1/controlled_vocabulary_terms` endpoint
- Extracts are citable
- `modified` and `modifiedBy` fields to the COL data package exporter [#3464]
- Pagination to Labels and TypeMaterial .json endpoints [#3472]
- DataAttribute columns for CollectingEvent and TaxonName filters
- Added ranks for viruses
- CachedMap framework - compute low-resolution maps quickly [#3010]
- .json and .geojson endpoints implement CachedMaps at `/api/v1/otus/:id/inventory/distribution`
- Administrator dashboard for CachedMap status
- New indices for some name/cached related fields (Otu, TaxonName, Source)
- Batch update Geographic area radial to filter collecting events
- Customized API version of OTU autocomplete
- GBIF map tiles as an option on maps
- `Add related` option to nodes in Biological associations graph task
- Layout settings for New image task

### Changed

- Predicted adjectives for the epithets ending with -ger and -fer
- Optimized Gnfinder playground new-name detection
- Optimized `/api/v1/asserted_distribution`, also now uses `extend[]=geo_json` (disabled if > 50 records requested)
- Updated `/api/v1/biological_associations` to report full `taxonomy` [#3438]
- Updated Ruby gems
- Added date format recognition ####-##-## [#3453]
- Add hyperlinks to OTU labels in Filter biological associations table [#3444]
- Updated many relationships to validate based on presence of objects, rather than parameters
- Simplified behavior of Otu and TaxonName autocomplete to use new fuzzier indicies
- Clone loan button redirects to new loan task [#3462]
- Multiple improvements in DwC importers

### Fixed

- Georeference parsing didn't handle new Z
- Clearing PinboardItems by class
- Rendering TNT matrix labels
- Initializing new Extract when no Extracts present
- DataAttribute filter facet not working for non-exact matches
- Speed response for Filter's returning DataAttributes [#3452]
- Going from Image filter to others could result in duplicated rows
- DWCA Importer: Geographic Areas not imported [#1852]
- Error on catalog_helper: history_other_name
- Error on taxon_name_relationship on rank_name.
- Create new asserted distribution when `is_absent` is checked in New asserted distribution task
- Repository selection does not appear in Filter Collection Objects [#3430]
- Docker pointing to outdated base image.
- Global identifiers resolve check not honouring HTTPS
- Interactive keys were not properly scoping to projects in some cases
- Annotations were sometimes added to objects that no longer existed [#3445]
- Disable editing of imported rows in DwC importer task [#3469]
- Fixed URL hostname string matching in some places.
- Matrix Column Coder throws an error after autosave ends and observation to be saved no longer exists
- New line delimiter doesn't work in Filter collection object [#3480]

[#1852]: https://github.com/SpeciesFileGroup/taxonworks/issues/1852
[#3010]: https://github.com/SpeciesFileGroup/taxonworks/issues/3010
[#3430]: https://github.com/SpeciesFileGroup/taxonworks/issues/3430
[#3438]: https://github.com/SpeciesFileGroup/taxonworks/issues/3438
[#3444]: https://github.com/SpeciesFileGroup/taxonworks/issues/3444
[#3445]: https://github.com/SpeciesFileGroup/taxonworks/issues/3445
[#3452]: https://github.com/SpeciesFileGroup/taxonworks/issues/3452
[#3462]: https://github.com/SpeciesFileGroup/taxonworks/issues/3462
[#3464]: https://github.com/SpeciesFileGroup/taxonworks/issues/3464
[#3469]: https://github.com/SpeciesFileGroup/taxonworks/issues/3469
[#3472]: https://github.com/SpeciesFileGroup/taxonworks/issues/3472
[#3480]: https://github.com/SpeciesFileGroup/taxonworks/issues/3480

## [0.33.1] - 2023-05-25

### Added

- NOMEN batch importer error handling/reporting improvements [#3427]
- More annotation-related facets to Observations filter

### Changed

- Autocomplete requests optimized by speed
- NOMEN batch importer treats authors only as verbvatim, Roles are no longer created.
- Upgraded to Node 18 LTS

### Fixed

- Without depictions filter facets
- Descriptors facets referencing observation/matrix presence/absence
- Errors on taxon_name.rank_name and paper_catalogue.combination
- Documents facet in Source filter
- Documents from other projects appearing in count on radial annotator [#3348]
- Verbatim name contained 'Suffix' [#3425]
- Observation matrix facet doesn't work in Filter descriptors
- Lock Is original and Is absent checkboxes in citation form
- Pagination doesn't work correctly in Filter biological associations [#3426]
- Records per page doesn't work on page change in Citations by source task

[#3348]: https://github.com/SpeciesFileGroup/taxonworks/issues/3348
[#3425]: https://github.com/SpeciesFileGroup/taxonworks/issues/3425
[#3426]: https://github.com/SpeciesFileGroup/taxonworks/issues/3426
[#3427]: https://github.com/SpeciesFileGroup/taxonworks/issues/3427

## [0.33.0] - 2023-05-19

### Added

- Basic RCC5 support (= OtuRelationship) [#257]
- Unified filter to observation matrix integration [#3415]
- Biological associations can now be depicted
- Data depiction facets
- Biological associations filter annotation-based facets
- New stage-only staged image type [#3400]
- New left-t stage layout [#3367]
- `Add` button to add biological associations from `Related` modal in new biological associations task
- ImportDataset facet in Filter collection objects [#3419]

### Changed

- Updated author and year string for family-group names
- Recent predicate list
- Recent languages list
- People autocomplete
- GeographicArea autocomplete (exact match on alternate value)

### Fixed

- Nomen (was "castor") batch load was not assigning parent correctly [#3409]
- Source and People API endpoints don't try to authenticate [#3407]
- Date range in filter Collection Object not being applied [#3418]
- Year import in NOMEN (was "castor") import [#3411]
- PublicContent missing is_community? method preventing reporting.
- Loans dashboard fails to render when no loans are present
- Staged image processing when boundaries fail to be calculated and calculate incorrectly
- Bug with engine in interactive keys [#3416]
- Collection object classification summary [#3412]
- BibTeX typo [#3408]
- Includes `type material` and `type material observations` don't work in Filter images
- Changing the number of items per page or the page shows loan items that are not from the current loan in New/edit loan task [#3413]
- Sort by name gives an wrong order in filter nomenclature task

[#257]: https://github.com/SpeciesFileGroup/taxonworks/issues/257
[#3367]: https://github.com/SpeciesFileGroup/taxonworks/issues/3367
[#3400]: https://github.com/SpeciesFileGroup/taxonworks/issues/3400
[#3407]: https://github.com/SpeciesFileGroup/taxonworks/issues/3407
[#3408]: https://github.com/SpeciesFileGroup/taxonworks/issues/3408
[#3409]: https://github.com/SpeciesFileGroup/taxonworks/issues/3409
[#3411]: https://github.com/SpeciesFileGroup/taxonworks/issues/3411
[#3412]: https://github.com/SpeciesFileGroup/taxonworks/issues/3412
[#3413]: https://github.com/SpeciesFileGroup/taxonworks/issues/3413
[#3415]: https://github.com/SpeciesFileGroup/taxonworks/issues/3415
[#3416]: https://github.com/SpeciesFileGroup/taxonworks/issues/3416
[#3418]: https://github.com/SpeciesFileGroup/taxonworks/issues/3418
[#3419]: https://github.com/SpeciesFileGroup/taxonworks/issues/3419

## [0.32.3] - 2023-05-05

### Added

- Add/move/return collection objects from collection object filter [#3387]
- Interpretation help for `full name` facet in people filter [#3394]
- Total individuals to loan show/recipient form [#3398]
- Download SVG button in Biological associations graph task
- Related modal in Biological associations graph task
- Return BibTeX with `extend[]=bibtex` on calls to `/api/v1/sources`
- Related button to biological associations in Browse OTU
- Pagination for loan items in Edit/new loan task [#3391]
- Caption and figure label editable in Depictions list in Radial annotator [#3396]

### Changed

- Pagination headers are exposed via CORS [#3380]
- Updated bundle gems
- Ruby 3.2 is now required as minimum
- API /people and /sources resources no longer require authentication [#3385]
- The genus rank is allowed as incertae sedis
- Trigger filter after change records per page selector
- Always show pin button
- Browse OTU biological association table contains related modal

### Fixed

- Global identifiers not appearing on community data [#3393]
- Lag in selecting loan items on edit loan [#3399]
- Collection object was loanable 2x in some cases
- An issue when geo-json related facets were not being applied in Otu filter
- Image filter with `otu_id` only returns as expected
- Depictions/Images facet not consistent and broken [#3395]
- Missing pagination for asserted_distributions API endpoint [#3377]
- Delete wrong node in Biological associations graph [#3383]
- Cannot clear `Returned on date` input for loan items in Edit/new loan task [#3390]

[#3377]: https://github.com/SpeciesFileGroup/taxonworks/issues/3377
[#3380]: https://github.com/SpeciesFileGroup/taxonworks/issues/3380
[#3382]: https://github.com/SpeciesFileGroup/taxonworks/issues/3382
[#3383]: https://github.com/SpeciesFileGroup/taxonworks/issues/3383
[#3385]: https://github.com/SpeciesFileGroup/taxonworks/issues/3385
[#3387]: https://github.com/SpeciesFileGroup/taxonworks/issues/3387
[#3390]: https://github.com/SpeciesFileGroup/taxonworks/issues/3390
[#3391]: https://github.com/SpeciesFileGroup/taxonworks/issues/3391
[#3393]: https://github.com/SpeciesFileGroup/taxonworks/issues/3393
[#3394]: https://github.com/SpeciesFileGroup/taxonworks/issues/3394
[#3395]: https://github.com/SpeciesFileGroup/taxonworks/issues/3395
[#3396]: https://github.com/SpeciesFileGroup/taxonworks/issues/3396
[#3398]: https://github.com/SpeciesFileGroup/taxonworks/issues/3398
[#3399]: https://github.com/SpeciesFileGroup/taxonworks/issues/3399

## [0.32.2] - 2023-04-03

### Added

- Geographic area smart-selector has click-to-select map option [#3293]
- Add collection object quick forms in New type specimen task
- New layout for collection objects filter - Data attributes
- DarwinCore`asscociatedTaxa` indexing via data attributes [#3371]

### Fixed

- Paper catalog raised when rendering some type material records [#3364]
- Lock buttons are not working on New source task
- Some rows don't show name string in Citations by source task [#3370]
- Updating a data attributes updates related DwcOccurrences
- API catalog method call [#3368]
- Alternate values appear on community data [#3363]

### Changed

- Updated bundle gems
- New D3 engine for object graph greatly improves performance, new rendering options
- New DwC occurrence version reflecting [#3371]

[#3363]: https://github.com/SpeciesFileGroup/taxonworks/issues/3363
[#3364]: https://github.com/SpeciesFileGroup/taxonworks/issues/3364
[#3368]: https://github.com/SpeciesFileGroup/taxonworks/issues/3368
[#3293]: https://github.com/SpeciesFileGroup/taxonworks/issues/3293
[#3371]: https://github.com/SpeciesFileGroup/taxonworks/issues/3371
[#3370]: https://github.com/SpeciesFileGroup/taxonworks/issues/3370

## [0.32.1] - 2023-03-23

### Fixed

- Date related rendering error in Catalog

## [0.32.0] - 2023-03-22

### Added

- New biological association task [#1638], in part [#2143]
- New options to extend results in Nomenclature filter [#3361]
- New panels for Adminstrators User activity dashboard
- Deaccessioned layout for filter collection objects

### Changed

- Replace GeoJSON long/lat format to lat/long on interfaces [#3359]
- Returned ability to show TaxonNameClassifications (from `/taxon_name_classifications/list`)

### Fixed

- Deaccessioned facet in Filter collection objects [#3352]
- Reversed OTU taxon name facet [#3360]
- Relationships are not listed in biological associations form in Quick forms
- Topics are not listed after create them on Citation form in Quick forms
- Combination names are missing in Citations by source
- Handle another class of SQED raises
- TaxonNameClassification API call raises
- Raises related to cached_nomenclature_date
- PublicContent causing OTU destruction to raise
- Several paper-catalog rendering issues
- Geographic area smart selector is not rendering correctly on Common names slice in Quick Forms

[#1638]: https://github.com/SpeciesFileGroup/taxonworks/issues/1638
[#2143]: https://github.com/SpeciesFileGroup/taxonworks/issues/2143
[#3352]: https://github.com/SpeciesFileGroup/taxonworks/issues/3352
[#3359]: https://github.com/SpeciesFileGroup/taxonworks/issues/3359
[#3360]: https://github.com/SpeciesFileGroup/taxonworks/issues/3360
[#3361]: https://github.com/SpeciesFileGroup/taxonworks/issues/3361

## [0.31.3] - 2023-03-17

### Added

- JSON nomenclature inventory endpoint `/api/v1/taxon_names/:id/inventory/catalog`

### Fixed

- Serial name filter query doesn't work
- Serial facet <IN WHERE>
- Authors facet doesn't work on Filter nomenclature
- Fixed bug preventing combination update
- Loan facet doesn't work on Filter collection objects [#3345]
- Valid name is not provided for all matches on Match nomenclature task [#3343]
- Object links don't work on Interactive key
- Alternate values on ObservationMatrix name failing
- Start and End date in Collecting Event related facets

### Changed

- Updated Ruby gems
- nomenclature related validation changed from nomenclature_date to cached_nomenclature_date, which should speadup the process

[#3343]: https://github.com/SpeciesFileGroup/taxonworks/issues/3343
[#3345]: https://github.com/SpeciesFileGroup/taxonworks/issues/3345

## [0.31.2] - 2023-03-09

### Added

- Link from AssertedDistribution filter to BiologicalAssociations filter
- All tab to biological relationships facet [#3334]
- Biological Property to Manage controlled vocabulary terms

### Changed

- Add nomenclature code to relationships and statuses labels in Filter nomenclature [#3333]
- All Loan edit requests resolve to the edit task [#3330]

### Fixed

- Biological association filter raises [#3335]
- Mass annotator for Sources showed no options
- People filtering doesn't work on Filter nomenclature [#3332]
- Biological associations section shows incorrect results in Browse Otu [#3336]
- Error message on Combination [#3340]
- `Clone last citation` button doesn't work
- Missing asserted distributions in Browse OTU and Quick forms radial [#3337]

[#3330]: https://github.com/SpeciesFileGroup/taxonworks/issues/3330
[#3332]: https://github.com/SpeciesFileGroup/taxonworks/issues/3332
[#3333]: https://github.com/SpeciesFileGroup/taxonworks/issues/3333
[#3334]: https://github.com/SpeciesFileGroup/taxonworks/issues/3334
[#3335]: https://github.com/SpeciesFileGroup/taxonworks/issues/3335
[#3336]: https://github.com/SpeciesFileGroup/taxonworks/issues/3336
[#3337]: https://github.com/SpeciesFileGroup/taxonworks/issues/3337

## [0.31.1] - 2023-03-07

### Fixed

- Radial annotator documentation shows too much [#3326]
- Cached values not updated [#3324]
- Roles not displaying while edint loan [#3327]
- Loan autocomplete [#3329]
- `Set as current` button doesn't work on Original combination section in New taxon name task [#3325]
- Repository autocomplete [#3331]
- Some staged filter results failing to set size of window [#3328]
- Fixed repository, source, serial, people autocomplete with new project_id param. New specs added
- Short URLs not working due to Ruby 3.2 incompatibility.

### Changed

- `/combinations/<id>` redirects to `/taxon_names/<id>`

[#3328]: https://github.com/SpeciesFileGroup/taxonworks/issues/3328
[#3331]: https://github.com/SpeciesFileGroup/taxonworks/issues/3331
[#3329]: https://github.com/SpeciesFileGroup/taxonworks/issues/3329
[#3327]: https://github.com/SpeciesFileGroup/taxonworks/issues/3327
[#3326]: https://github.com/SpeciesFileGroup/taxonworks/issues/3326
[#3325]: https://github.com/SpeciesFileGroup/taxonworks/issues/3325
[#3324]: https://github.com/SpeciesFileGroup/taxonworks/issues/3324

## [0.31.0] - 2023-03-07

### Added

- Filter asserted distributions task [#1035]
- Filter biological associations task [#1156]
- Filter content task
- Filter descriptors task [#2802]
- Filter loans task [#2124]
- Filter observations task [#3291] [#3062]
- Filters can mass-annotate select rows (e.g. Notes, Citations) [#2257] [#2340]
- Filter collection objects with/out preparations [#2937]
- Filter collecting events with/out any date value, verbaitm or parsed [#2940]
- Filter collecting events with any/no value in field (covers, in part [#2756])
- Collection object filter - add with/out local identifiers facet [#2699]
- Collection object filter - de-accession facet [#3195]
- Data attributes facet returns results matching/without any predicate value
- Integrated filters (pass results from one to another) [#2652] Also in full/part [#1649] [#1744] [#2178] [#2147] [#2770]
- Match identifiers facet added across filters/API [#3151] [#3058]
- Nomenclature filter - facets for names with/out citations and with/out documentation [#2865]
- Nomenclature filter - facet for by year described [#2059]
- Nomenclature filter - facet to return names with/out (subsequent) combinations [#3051]
- Nomenclature filter - facet to for with/out original combination [#2496]
- Protocol facet to collection object, collecting event filters [#2803]
- Task - Loans dashboard [#2116] (in part)
- Task - Source citation totals (linked from Source filter) [#2305]
- Ability to "coordinatify" an OTU filter result [#3317]
- Figure label in label on image API response
- Input to create N records in Simple new specimen [#3269]
- Soft_validation for seniority of synonyms
- Added `cached_author` to TaxonName

### Fixed

- Local identifier facet in filter CollectionObject [#3275]
- Identifier within range includes +1,-1 results [#2179]
- Data attribute facets [#3075]
- Collection object filter finds objects by container identifiers [#1240]
- Clarified collection object loan facet [#3005]
- Radius based map searchers returned intersections, not covering results [#2552]
- Data attributes not appending to DwC export [#3280]
- DwC download from CollectionObject "not downloading"/closing [#3313]
- Filter nomenclature returns original combination when there is none [#3024]
- Staged image visualization incorrectly cropped [#3260]
- Staged images incorrectly returning records with local-identified containers [#3258]
- PK sequences was not setup in the correct dump stage in Export project task occasionally causing PK constraints errors on usage.
- Radial object redirects to `Data` page after destroy a collection object in Simple new specimen task [#3284]
- Wrong label for display unscored columns in Matrix column coder [#3292]
- Duplicate records in nomenclature match task [#3300]
- NeXML rendering bug
- Breaking CoL export bug [#3310]

### Changed

- Unified look and feel of all filters [#445] [#1677]
- Filter OTUs completely rebuilt, numerous new facets [#1633]
- Filter collection objects displays (customizable) columns of many types, not just DwC [#3197] [#2931]
- Unified form of filter/API `*_ids` and `*_id` parameters to always use singular [#2188]
- Merged 'Task - Overdue loans' with Loans dashboard [#2116]
- Export project task now removes hierarchies rows that don't belong to selected project [#3271]
- Export project task no longer includes `delayed_jobs` and `imports` tables.
- Clipboard hotkey combination [#3273]
- Recently used confidence levels improvements
- Multiple nomenclatural soft validation improvements
- Improvements to intelligence of various autocompletes
- Improved cursor focus on new source task
- Update Ruby to 3.2.1
- Updated Ruby gems
- Updated Docker container (including psql client version to 15)

[#445]: https://github.com/SpeciesFileGroup/taxonworks/issues/445
[#1035]: https://github.com/SpeciesFileGroup/taxonworks/issues/1035
[#1156]: https://github.com/SpeciesFileGroup/taxonworks/issues/1156
[#1240]: https://github.com/SpeciesFileGroup/taxonworks/issues/1240
[#1633]: https://github.com/SpeciesFileGroup/taxonworks/issues/1633
[#1649]: https://github.com/SpeciesFileGroup/taxonworks/issues/1649
[#1667]: https://github.com/SpeciesFileGroup/taxonworks/issues/1677
[#1744]: https://github.com/SpeciesFileGroup/taxonworks/issues/1744
[#2059]: https://github.com/SpeciesFileGroup/taxonworks/issues/2059
[#2116]: https://github.com/SpeciesFileGroup/taxonworks/issues/2116
[#2124]: https://github.com/SpeciesFileGroup/taxonworks/issues/2124
[#2147]: https://github.com/SpeciesFileGroup/taxonworks/issues/2147
[#2178]: https://github.com/SpeciesFileGroup/taxonworks/issues/2178
[#2179]: https://github.com/SpeciesFileGroup/taxonworks/issues/2179
[#2188]: https://github.com/SpeciesFileGroup/taxonworks/issues/2188
[#2257]: https://github.com/SpeciesFileGroup/taxonworks/issues/2257
[#2305]: https://github.com/SpeciesFileGroup/taxonworks/issues/2305
[#2340]: https://github.com/SpeciesFileGroup/taxonworks/issues/2340
[#2496]: https://github.com/SpeciesFileGroup/taxonworks/issues/2496
[#2552]: https://github.com/SpeciesFileGroup/taxonworks/issues/2552
[#2652]: https://github.com/SpeciesFileGroup/taxonworks/issues/2652
[#2699]: https://github.com/SpeciesFileGroup/taxonworks/issues/2699
[#2756]: https://github.com/SpeciesFileGroup/taxonworks/issues/2756
[#2770]: https://github.com/SpeciesFileGroup/taxonworks/issues/2770
[#2802]: https://github.com/SpeciesFileGroup/taxonworks/issues/2802
[#2803]: https://github.com/SpeciesFileGroup/taxonworks/issues/2803
[#2865]: https://github.com/SpeciesFileGroup/taxonworks/issues/2865
[#2931]: https://github.com/SpeciesFileGroup/taxonworks/issues/2931
[#2937]: https://github.com/SpeciesFileGroup/taxonworks/issues/2937
[#2940]: https://github.com/SpeciesFileGroup/taxonworks/issues/2940
[#3005]: https://github.com/SpeciesFileGroup/taxonworks/issues/3005
[#3024]: https://github.com/SpeciesFileGroup/taxonworks/issues/3024
[#3051]: https://github.com/SpeciesFileGroup/taxonworks/issues/3051
[#3058]: https://github.com/SpeciesFileGroup/taxonworks/issues/3058
[#3062]: https://github.com/SpeciesFileGroup/taxonworks/issues/3062
[#3075]: https://github.com/SpeciesFileGroup/taxonworks/issues/3075
[#3151]: https://github.com/SpeciesFileGroup/taxonworks/issues/3151
[#3195]: https://github.com/SpeciesFileGroup/taxonworks/issues/3195
[#3197]: https://github.com/SpeciesFileGroup/taxonworks/issues/3197
[#3258]: https://github.com/SpeciesFileGroup/taxonworks/issues/3258
[#3260]: https://github.com/SpeciesFileGroup/taxonworks/issues/3260
[#3269]: https://github.com/SpeciesFileGroup/taxonworks/issues/3269
[#3271]: https://github.com/SpeciesFileGroup/taxonworks/issues/3271
[#3273]: https://github.com/SpeciesFileGroup/taxonworks/issues/3273
[#3275]: https://github.com/SpeciesFileGroup/taxonworks/issues/3275
[#3280]: https://github.com/SpeciesFileGroup/taxonworks/issues/3280
[#3284]: https://github.com/SpeciesFileGroup/taxonworks/issues/3284
[#3291]: https://github.com/SpeciesFileGroup/taxonworks/issues/3291
[#3292]: https://github.com/SpeciesFileGroup/taxonworks/issues/3292
[#3300]: https://github.com/SpeciesFileGroup/taxonworks/issues/3300
[#3310]: https://github.com/SpeciesFileGroup/taxonworks/issues/3310
[#3313]: https://github.com/SpeciesFileGroup/taxonworks/issues/3313
[#3317]: https://github.com/SpeciesFileGroup/taxonworks/issues/3317

## [0.30.3] - 2023-01-04

### Added

- Search panel in New source task

### Fixed

- Programming error breaking loop with `exit` instead of `break` when calculating previous OTU.
- Crash when attempting to view a `Verbatim` source because BibTeX panel cannot work with that type of sources.

### Changed

- Updated Ruby gems.

## [0.30.2] - 2022-12-20

### Fixed

- Asserted distribution citation label in Browse OTU
- Records per page selector doesn't work in Filter Stage Images [#3259]
- In NeXML output, TIFF images were not converted to JPG
- Error when calculating previous OTU for navigation

### Changed

- Updated Ruby gems.

[#3259]: https://github.com/SpeciesFileGroup/taxonworks/issues/3259

## [0.30.1] - 2022-12-16

### Added

- BibTeX type facet for Filter sources task [#3218]
- With/without Source::Bibtex title in Filter source task [#3219]
- Hyperling names in Nomenclature match

### Fixed

- "Remarks" column displays in Browse collection object DwC/gbifference panel
- Browse OTU navigation dead ends [#3056]
- Setting a Namespace to virtual updates cache properly [#3256]
- Virtual namespaces identifier tags don't include duplicated Namespace [#3256]
- Virtual namespace identifier preview does not render namespace
- Incorrect valid name in Nomenclature match task

[#3056]: https://github.com/SpeciesFileGroup/taxonworks/issues/3056
[#3256]: https://github.com/SpeciesFileGroup/taxonworks/issues/3256
[#3218]: https://github.com/SpeciesFileGroup/taxonworks/issues/3218
[#3219]: https://github.com/SpeciesFileGroup/taxonworks/issues/3219

## [0.30.0] - 2022-12-15

### Added

- CoL data package improvements for Remarks, metadata,
- Integrated GBIF remarks flags into Browse collection object [#3136]
- Next/previous navigation arrows to Browse collection object [#3229]
- More details to steps in stepwise determinations task
- Added soft validation for duplicate family group name forms and misspellings [#3185]
- With/out local identifier facet for collection objects and stagd images [#3173]
- Filter by housekeeping and staged-image data attributes [#3171]
- Delete selected collection objects (and their related data) from filter [#3174]
- Collection object Autocomplete has loan and deaccession banners [#3192]
- Autocomplete on Browse collection object [#3189]
- Task - Collection object chronology, a plot of object by year collected, that's all
- Endpoint to return related data preventing or included in destroy, e.g. `/metadata/related_summary?klass=CollectionObject&id[]=16701&id[]...`
- Filter by gender and form classifications in filter nomenclature [#3212]
- Serial facet to Filter sources [#3211]
- `tooltips` and `actions` configuration properties to Map component [#3234]

### Fixed

- White-space around unit-tray headers [#3191]
- Stepwise determinations confounded by invisible white-space [#3009]
- OTU smart selector did not include items from the pinboard [#3139]
- Source in n project autocomplete response [#3142]
- 'Also create OTU' on batch taxon name upload causing raise
- Media observations removed if they have no more depictions via updates
- Citation link in biological association panel on Browse OTU
- Type relationship text/rendering is inverted in New taxon name task [#3182]
- Sqed processing failing to encode HEIC images [#3188]
- Common list component doesn't filter created status on New taxon name task [#3205]
- Collectors facet doesn't work on Filter collecting event [#3216]
- original combination label disappears when relationship doesn't include the current taxon name [#3067]
- Sometimes keyboard table is duplicating shortcuts
- Export Project Database task not exporting rows whose `project_id` is `NULL` [#3203]
- Close icon is difficult to distinguish when modal background is transparent [#3245]
- Missing identifiers and determinations on collection object table in New collecting event task [#3246]
- Click "Manage Synonymy" in Edit Taxon Name task does not redirect [#3250]

### Changed

- Behaviour of recent records (smart selectors) updated to reference updates, not just created timestamps
- Lock, navigation, UI, and code refreshments to Simple new specimen [#3190]
- "TODO list" now a faceted search named 'Filter staged images' [#3171]
- Refactored observation cell component for Image matrix
- Updated Ruby gems
- Webpack binaries: Replaced `npm bin` for `npm root` to allow compatibility with recent NPM versions
- Nomenclature match updates [#2176]
- Navigation key combination for radial annotator [#3233]
- Truncate smart selector lists
- Allow compare n objects in collection object match [#3238]
- Include total of match/unmatched in Collection object match [#3237]

[#2176]: https://github.com/SpeciesFileGroup/taxonworks/issues/2176
[#3009]: https://github.com/SpeciesFileGroup/taxonworks/issues/3009
[#3136]: https://github.com/SpeciesFileGroup/taxonworks/issues/3136
[#3139]: https://github.com/SpeciesFileGroup/taxonworks/issues/3139
[#3171]: https://github.com/SpeciesFileGroup/taxonworks/issues/3171
[#3173]: https://github.com/SpeciesFileGroup/taxonworks/issues/3173
[#3174]: https://github.com/SpeciesFileGroup/taxonworks/issues/3174
[#3182]: https://github.com/SpeciesFileGroup/taxonworks/issues/3182
[#3188]: https://github.com/SpeciesFileGroup/taxonworks/issues/3188
[#3189]: https://github.com/SpeciesFileGroup/taxonworks/issues/3189
[#3190]: https://github.com/SpeciesFileGroup/taxonworks/issues/3190
[#3191]: https://github.com/SpeciesFileGroup/taxonworks/issues/3191
[#3192]: https://github.com/SpeciesFileGroup/taxonworks/issues/3192
[#3203]: https://github.com/SpeciesFileGroup/taxonworks/issues/3203
[#3205]: https://github.com/SpeciesFileGroup/taxonworks/issues/3205
[#3211]: https://github.com/SpeciesFileGroup/taxonworks/issues/3211
[#3212]: https://github.com/SpeciesFileGroup/taxonworks/issues/3212
[#3216]: https://github.com/SpeciesFileGroup/taxonworks/issues/3216
[#3229]: https://github.com/SpeciesFileGroup/taxonworks/issues/3229
[#3233]: https://github.com/SpeciesFileGroup/taxonworks/issues/3233
[#3234]: https://github.com/SpeciesFileGroup/taxonworks/issues/3234
[#3238]: https://github.com/SpeciesFileGroup/taxonworks/issues/3238
[#3245]: https://github.com/SpeciesFileGroup/taxonworks/issues/3245
[#3246]: https://github.com/SpeciesFileGroup/taxonworks/issues/3246
[#3250]: https://github.com/SpeciesFileGroup/taxonworks/issues/3250

## [0.29.6] - 2022-11-08

### Added

- Print unit-tray headers from TaxonNames via Filter nomenclature [#3160]
- New radial "Filter" navigators facilitating cross-linking to filters [#2297]
- Option to force DwC indexing to prioritize names from Geographic Area [#3143]
- Functionality to update CollectingEvents in the context of Browse collection object
- Character state filter in Matrix Column Coder [#3141]
- Better error handling and reporting when parsing BibTeX
- Index for caching the numeric component of Identifiers

### Changed

- Updated Browse collection object interface [#2297]
- Reload New source task by pressing New and loading source
- Updated Ruby gems
- Updated node packages

### Fixed

- Incorrect soft validation message on TaxonName relationship [#3184]
- Browse nomenclature crashing when taxon name descendants have no cached author year
- Soft validation crashing when cached nomenclature date is absent
- Role picker is missing after create a source from BibTeX [#3180]

[#3160]: https://github.com/SpeciesFileGroup/taxonworks/issues/3160
[#2297]: https://github.com/SpeciesFileGroup/taxonworks/issues/2297
[#3143]: https://github.com/SpeciesFileGroup/taxonworks/issues/3143
[#3141]: https://github.com/SpeciesFileGroup/taxonworks/issues/3141
[#3180]: https://github.com/SpeciesFileGroup/taxonworks/issues/3180

## [0.29.5] - 2022-10-10

### Changed

- Source cached_value calculation [#3181]
- Changed author labels on Filter source [#3134]
- Minor changes to plots on administration activity dashboard
- Parallelize some indexing rake tasks

### Fixed

- Recent and Quick list are empty on Citation annotator [#3133]

[#3133]: https://github.com/SpeciesFileGroup/taxonworks/issues/3133
[#3134]: https://github.com/SpeciesFileGroup/taxonworks/issues/3134

## [0.29.4] - 2022-10-07

### Added

- Distribution, Material Examined sections, and zip download for paper catalog [#3098]
- Code full columns, destroy all observations in a column [#3117]
- "Display only unscored rows" on Matrix column coder [#3103]
- Previous and next links in Matrix row coder [#3107]
- Match identifiers facet to Filter extract task [#3089]
- `Clone previous citation` to citation panels [#3097]
- `scientificName` is now implied in `typeStatus` when only the type of type is specified in DwC occurrences importer
- Additional DwC classification terms [#3118]

### Fixed

- Broken URL for images in NeXML [#2811]
- Improved Confidence annotation speed [#3126]
- Destroying a Georefernce re-indexes related CollectingEvent [#3114]
- Numerous issues in "Castor" TaxonName batch load
- CollectingEvent cached geo-names (e.g. used in DwC export) missclassified [#2614]
- Order of descriptors in nexus and tnt output is updated to reflect the column ordering
- Homonyms without replacement name are now marked as invalid
- Visible identifiers raising (e.g. broken object graph)
- Presence Descriptor is not saving in Matrix row coder [#3099]
- Missing number of objects for presence/absence descriptors on Interactive keys [#3102]
- `New column` button doesn't add the new column to the interface [#3109]
- Taxonomy inventory API failing with common names when language is not set
- Missing taxon_name_relationships parameters [#3096]
- Create matrix row button redirects to wrong OTU in OTU radial
- Determinations not added to containers in "Edit Loan"task [#1935]
- OTU images disappear when moving other images to observation cells [#3111]
- Basic nomenclature failing to redirect when no name was selected
- List of All Topics is not displayed [#3125]
- Refactor confidence form [#3129]
- Destroy selected Labels does not work [#3127]
- Creating multiple type materials in comprehensive task [#3131]
- DwC occurrences importer not reporting error when `typeStatus` is non-empty and yet it doesn't have correct format
- Interactive key - Presence / absence descriptors are placed in non relevant list [#3100]

### Changed

- Removed New OTU link from New observation matrix task [#3101]
- Disabled horizontal resizing for textarea inputs on comprehensive

[#3100]: https://github.com/SpeciesFileGroup/taxonworks/issues/3100
[#3101]: https://github.com/SpeciesFileGroup/taxonworks/issues/3101
[#2811]: https://github.com/SpeciesFileGroup/taxonworks/issues/2811
[#3118]: https://github.com/SpeciesFileGroup/taxonworks/issues/3118
[#3126]: https://github.com/SpeciesFileGroup/taxonworks/issues/3126
[#3117]: https://github.com/SpeciesFileGroup/taxonworks/issues/3117
[#3114]: https://github.com/SpeciesFileGroup/taxonworks/issues/3114
[#2614]: https://github.com/SpeciesFileGroup/taxonworks/issues/2614
[#1935]: https://github.com/SpeciesFileGroup/taxonworks/issues/1935
[#3089]: https://github.com/SpeciesFileGroup/taxonworks/issues/3089
[#3096]: https://github.com/SpeciesFileGroup/taxonworks/issues/3096
[#3097]: https://github.com/SpeciesFileGroup/taxonworks/issues/3097
[#3099]: https://github.com/SpeciesFileGroup/taxonworks/issues/3099
[#3102]: https://github.com/SpeciesFileGroup/taxonworks/issues/3102
[#3103]: https://github.com/SpeciesFileGroup/taxonworks/issues/3103
[#3107]: https://github.com/SpeciesFileGroup/taxonworks/issues/3107
[#3109]: https://github.com/SpeciesFileGroup/taxonworks/issues/3109
[#3111]: https://github.com/SpeciesFileGroup/taxonworks/issues/3111
[#3125]: https://github.com/SpeciesFileGroup/taxonworks/issues/3125
[#3127]: https://github.com/SpeciesFileGroup/taxonworks/issues/3127
[#3129]: https://github.com/SpeciesFileGroup/taxonworks/issues/3129
[#3131]: https://github.com/SpeciesFileGroup/taxonworks/issues/3131

## [0.29.3] - 2022-09-13

### Fixed

- View image matrix button doesn't work in Interactive key task
- Missing collectors parameters in Filter collecting events.
- Pagination on Image Matrix task
- Project Preferences task causing internal server errors
- Boolean params not handled correctly on specific conditions in some filters

## [0.29.2] - 2022-09-08

### Added

- Administration level project classification visualization [#3092]
- Recent paramter to asserted distribution filter [#3086]

### Changed

- Updated Gemfile
- Handle long queries to match facets in filters [#3088]

### Fixed

- Collecting event filter matching user creator/updator broken [#3008]
- Rendering type material label with document label failed
- Failed attempts at destroying a Predicate no longer raise
- Prevent some breaking raises for Georeferences with invalid shapes
- Select all button doesn't work in Print labels task [#3093]

[#3088]: https://github.com/SpeciesFileGroup/taxonworks/issues/3088
[#3008]: https://github.com/SpeciesFileGroup/taxonworks/issues/3008
[#3086]: https://github.com/SpeciesFileGroup/taxonworks/issues/3086
[#3092]: https://github.com/SpeciesFileGroup/taxonworks/issues/3092
[#3093]: https://github.com/SpeciesFileGroup/taxonworks/issues/3093

## [0.29.1] - 2022-08-31

### Fixed

- Radial navigator for TaxonName broken [#3087]
- OTU link in New asserted distribution

[#3087]: https://github.com/SpeciesFileGroup/taxonworkseissues/3087

## [0.29.0] - 2022-08-30

### Added

- A simple paper catalog generator (preview!) [#1473]
- Functions to summarize distributions for catalogs
- GeographicAreas autocomplete references alternate values
- People filter, with many facets [#2876]
- Matches identifiers (results by delimited list of some identifier type) facet, to most filters [#3080]
- Crosslink by ID between CollectionObject and CollectingEvent filters
- `Open in filter collection object` button in Filter collecting event task
- Added `verbatim_label` support for Collecting Event Castor batch load. [#3059]
- Lock `is_original` and `is_absent` for Asserted distribution form in OTU quick forms [#3085]

### Fixed

- Local identifiers on community objects were displayed across projects
- Object type is missing when otu filter param is passed instead observation matrix id in Image matrix task

### Changed

- Alternate values can be used on GeographicAreas [#2506]
- Alternate values on community objects are shared by all projects
- Global identifiers on community objects are shared across all projects
- Optimized identifier next/previous, not fully resolved [#3078]
- Updated Ruby gems.
- Upgraded to newer Gnfinder service.
- Enabled 10km tolerance to geographic area validation for verbatim georeferences.

### Data

- Migrates annotations on Community objects to be accessilbe across projects

[#1473]: https://github.com/SpeciesFileGroup/taxonworks/issues/1473
[#2506]: https://github.com/SpeciesFileGroup/taxonworks/issues/2506
[#3078]: https://github.com/SpeciesFileGroup/taxonworks/issues/3078
[#2876]: https://github.com/SpeciesFileGroup/taxonworks/issues/2876
[#3059]: https://github.com/SpeciesFileGroup/taxonworks/pull/3059
[#3080]: https://github.com/SpeciesFileGroup/taxonworks/issues/3080
[#3085]: https://github.com/SpeciesFileGroup/taxonworks/issues/3085

## [0.28.1] - 2022-08-19

### Fixed

- Settings modal is scrolled to the bottom when the modal is open.
- `Edit in image matrix` and `Open in matrix` buttons don't open image matrix task on edit mode.
- `Create verbatim coordinates` button dissapears after create request fails in New collecting event task
- Depictions are not displayed correctly in Browse collecting event [#3012]
- Cloned georeference are not loaded after cloning a collecting event [#3076]

### Changed

- Updated Ruby gems.
- Updated Node packages.
- Expanded drag and drop section in observation cell in Image matrix

[#3012]: https://github.com/SpeciesFileGroup/taxonworks/issues/3012
[#3076]: https://github.com/SpeciesFileGroup/taxonworks/issues/3076

## [0.28.0] - 2022-08-08

### Added

- Added OriginallyInvalid relationship in ICN [#3315]
- Add `/api/v1/otus/123/inventory/content`, includes `embed[]=depictions` [#3004]
- Adds `data_attributes`, `data_attribute_value`, `data_attribute_predicate_id`, `data_attribute_exact` in filter concern [#2922]
- `/api/v1/tags` endpoint with `tag_object_type[]`,`tag_object_id[]`, `tag_object_type`, `object_global_id`, `keyword_id[]` [#3061]
- Added pagination in the image_matrix
- Matrix Column Coder - coding by descriptor [#1385]
- Soft validation and fix for adding subsequen combination when original combination is different [#3051]
- Added 'electronic only' field for the source to flag sources published in electronic only format
- Default `collectionCode` namespace mappings as falback when `institutionCode`:`collectionCode` mappings do not contain a match in DwC occurrences importer.

- Remove search box in observation matrix hub [#3032]
- Type material form allows multiple type species in comprehensive task. [#2584]
- Updated Ruby gems.Yes
- wikidata-client dependency is now fetching from RubyGems rather than custom fork.
- serrano has been changed to a new custom branch which is identical to official gem except `thor` dependency has been downgraded for TW compatibility.
- DwC occurrences importer mappings are not sorted by `institutionCode`:`collectionCode`

### Fixed

- Object global id param in identifiers API/filter
- Bad logic check on adding new user to project
- Dependency loop problem in DwC checklist importer
- Image matrix error

[#3004]: https://github.com/SpeciesFileGroup/taxonworks/issues/3004
[#3061]: https://github.com/SpeciesFileGroup/taxonworks/issues/3061
[#1385]: https://github.com/SpeciesFileGroup/taxonworks/issues/1385
[#2584]: https://github.com/SpeciesFileGroup/taxonworks/issues/2584
[#3032]: https://github.com/SpeciesFileGroup/taxonworks/issues/3032
[#3051]: https://github.com/SpeciesFileGroup/taxonworks/issues/3051
[#2922]: https://github.com/SpeciesFileGroup/taxonworks/issues/2922

## [0.27.3] - 2022-07-20

### Added

- Soft_validation for the year of taxon description compared to person years of life [#2595]
- Pagination to Image matrix task

### Fixed

- Fixes rendering the author string in the catalogue [#2825]
- Include facet is not working properly in Filter nomenclature [#3023]
- Role picker changes order of roles after removing one [#3003]
- Observation matrix TNT export failed due to undefined method error [#3034]
- Date start and Date end display flipped in "Filter Collecting Events" [#3039]
- Role picker list doesn't display suffix and preffix
- By user facet is passing member id
- Project user last seen at correctly reported

### Changed

- Softvalidation message for new combination is rewarded
- The genus rank is allowed as incertae sedis
- ElectronicPulbications moved from NomenNudum to Unavailable.
- Updated Ruby gems and Node packages
- OTU name string into link in Observation matrices dashboard task

[#2825]: https://github.com/SpeciesFileGroup/taxonworks/issues/2825
[#2595]: https://github.com/SpeciesFileGroup/taxonworks/issues/2595
[#3003]: https://github.com/SpeciesFileGroup/taxonworks/issues/3003
[#3023]: https://github.com/SpeciesFileGroup/taxonworks/issues/3023
[#3034]: https://github.com/SpeciesFileGroup/taxonworks/issues/3034
[#3039]: https://github.com/SpeciesFileGroup/taxonworks/issues/3039

## [0.27.2] - 2022-06-22

### Fixed

- Updated csv output for an observation matrix [#3040]
- Content panel in browse OTU not working properly
- Darwin Core Export failing on specific combinations of data attributes selection.

### Changed

- Updated Ruby gems and Node packages

## [0.27.1] - 2022-06-21

### Changed

- People/Name toggle remove historical option for name [#3028]

### Fixed

- Content attributes response

[#3028]: https://github.com/SpeciesFileGroup/taxonworks/issues/3028

## [0.27.0] - 2022-06-17

### Added

- Task to manage pubilcation of Content to PublicContent [#3004] in part
- Task to merge taxon name relationships from one taxon to another [#3022]
- Add `determiner_name_regex` to collection object filter [#3026]
- API interactive key engine endpoint `/api/v1/observation_matrices/123/key.json`
- API depictions endpoint `api/v1/depictions/123.json?extend[]=image&extend[]=sqed_depiction&extend[]=figures`
- Taxon determinations stats in stats API
- Setting tags for collecting events and collection objects in DwC occurrences importer [#3019], [#2855]

### Changed

- Column order in Observation matrices dashboard task
- Size of description input in Protocol form
- Error code for merge people response

### Fixed

- Annotations panel doesn't display notes in Browse nomenclature
- Wildcard matches on collecting event attributes failing
- Select row in Observation matrices dashboard assigns incorrect ID
- Last week citations stats in API showing values for images. [#3020]
- Annotations panel doesn't display notes in Browse nomenclature
- Geographic areas download failing to generate CSV
- Flip is not working propertly in Uniquify people task

[#3004]: https://github.com/SpeciesFileGroup/taxonworks/issues/3004
[#3022]: https://github.com/SpeciesFileGroup/taxonworks/issues/3022
[#3026]: https://github.com/SpeciesFileGroup/taxonworks/issues/3026
[#3020]: https://github.com/SpeciesFileGroup/taxonworks/issues/3020
[#3019]: https://github.com/SpeciesFileGroup/taxonworks/pull/3018
[#2855]: https://github.com/SpeciesFileGroup/taxonworks/issues/2855

## [0.26.2] - 2022-06-05

### Changed

- Updated Ruby gems

### Fixed

- Filter collection object not working when attempting to show the record

## [0.26.1] - 2022-06-03

### Changed

- Upgraded to Ruby 3.1 [#3011]
- Updated Ruby gems

[#3011]: https://github.com/SpeciesFileGroup/taxonworks/pull/3011

## [0.26.0] - 2022-05-30

### Added

- Task - Stepwise determinations, facilitate verbatim to parsed determinations en masse [#2911]
- Two more digitization stage types, "T" and "Inverted T" [#2863]
- Added soft_validation fix to missing collection_object determination, when the type is designated [#2907]
- Confirmation button for tags, preparation type and repository panels in CO Match [#2995]

### Changed

- Upgraded Node to version 16
- Replaced Webpacker for Shakapacker gem
- Upgrade PDF viewer library

### Fixed

- Nomenclature and observation matrix stats [#1124] [#1356]
- Cannot add a determination after editing one in comprehensive task [#2996]
- "In project" button is not updated after select a different source in Edit source task [#3000]

[#1356]: https://github.com/SpeciesFileGroup/taxonworks/issues/1356
[#1124]: https://github.com/SpeciesFileGroup/taxonworks/issues/1124
[#2911]: https://github.com/SpeciesFileGroup/taxonworks/issues/2911
[#2863]: https://github.com/SpeciesFileGroup/taxonworks/issues/2863
[#2995]: https://github.com/SpeciesFileGroup/taxonworks/issues/2995
[#2996]: https://github.com/SpeciesFileGroup/taxonworks/issues/2996
[#3000]: https://github.com/SpeciesFileGroup/taxonworks/issues/3000

## [0.25.0] - 2022-05-19

### Added

- Link to Download project in show project [#2775]
- OTU geo-json inventory API endpoint, `/api/v1/otus/123/inventory/distribution`.
- Collection object classification summary task [#1864]
- Notes facet to Collection Objects filter [#2966]
- Confirmation modal for clone button on New collecting event task [#2978]
- Minutes/record estimate in project activity task [#2979]
- Pagination in Citations by source task
- Current repository facet in collection object filter [#2975]

### Changed

- Identifiers added to print labels [2959]
- Improved Extract tables [#2884] [#2881]
- Improved Repository autocomplete [#2993]
- Refactor citations by source task
- Person autocomplete optimization
- Cleaned up Label UI text
- Removed some jQuery
- Updated Ruby gems via `bundle update`
- Use Catalog for API source of OTU nomenclature citations

### Fixed

- taxonworks.csl update for stated date [#3021]
- Improved project activity to include current session [#3013]
- Extract/protocol UI issues [#2990]
- Source year_suffix preventing cloning [#2992]
- Dwca eml.xml file validates locally [#2986]
- Missing params for api_nomenclature_citations added
- Converted wkt parsing errors from exceptions to validation
- DwcOccurrence version scope to project in Hub
- Fixed soft validation on Collection Object related to determination date [#2949]
- Original combination soft validations are not loaded when New taxon name task is opened
- ObservationMatrixRow|ColumnItem index view failing because new links are not available
- Author roles are no visible in Citations by source task
- Increasing number of labels to print while label is selected _adds_ that many to preview [#2973]
- Geographic areas are not suggested based on verbatim coordinates in comprehensive and new collecting event task [#2982]
- Cannot sort by column in filter collecting event task [#2970]
- "Recent" determiners not working in Comprehensive [#2985]
- Determiners locked are missing after press "Save and new" in comprehensive task [#2943]
- Crashing when creating georeferences with invalid WKT input
- ObservationMatrixRow|Column index and autocomplete calls
- Lock source button is not working in OTU radial - biological associations form [#2989]
- New type specimen duplicates specimen when updated after creating [#2994]
- Sort column option is not working on Filter collection objects
- Toggle members buttons is not working on Browse annotator

[#2959]: https://github.com/SpeciesFileGroup/taxonworks/issues/2959
[#2775]: https://github.com/SpeciesFileGroup/taxonworks/issues/2775
[#2881]: https://github.com/SpeciesFileGroup/taxonworks/issues/2881
[#2884]: https://github.com/SpeciesFileGroup/taxonworks/issues/2884
[#2990]: https://github.com/SpeciesFileGroup/taxonworks/issues/2990
[#2992]: https://github.com/SpeciesFileGroup/taxonworks/issues/2992
[#2993]: https://github.com/SpeciesFileGroup/taxonworks/issues/2993
[#2986]: https://github.com/SpeciesFileGroup/taxonworks/issues/2986
[#1864]: https://github.com/SpeciesFileGroup/taxonworks/issues/1864
[#2943]: https://github.com/SpeciesFileGroup/taxonworks/issues/2943
[#2949]: https://github.com/SpeciesFileGroup/taxonworks/issues/2949
[#2966]: https://github.com/SpeciesFileGroup/taxonworks/issues/2966
[#2970]: https://github.com/SpeciesFileGroup/taxonworks/issues/2970
[#2973]: https://github.com/SpeciesFileGroup/taxonworks/issues/2973
[#2975]: https://github.com/SpeciesFileGroup/taxonworks/issues/2975
[#2978]: https://github.com/SpeciesFileGroup/taxonworks/issues/2978
[#2979]: https://github.com/SpeciesFileGroup/taxonworks/issues/2979
[#2982]: https://github.com/SpeciesFileGroup/taxonworks/issues/2982
[#2985]: https://github.com/SpeciesFileGroup/taxonworks/issues/2985
[#2994]: https://github.com/SpeciesFileGroup/taxonworks/issues/2994

## [0.24.5] - 2022-05-03

### Fixed

- Previously loaned and returned CollectionObjects are unloanable [#2964]
- People smart selector doesn't work to add new roles [#2963]
- Type species section is empty in Browse OTU
- Missing depictions caption and figure label in Image matrix task [#2965]

[#2964]: https://github.com/SpeciesFileGroup/taxonworks/issues/2964
[#2963]: https://github.com/SpeciesFileGroup/taxonworks/issues/2963
[#2965]: https://github.com/SpeciesFileGroup/taxonworks/issues/2965

## [0.24.4] - 2022-05-02

### Added

- Organization roles to taxon determinations model

### Fixed

- Repository autocomplete raises [#2960]
- Duplicated text in TaxonDetermination link [#2947]
- Housekeeping facet in CollectingEvent filter broken [#2957]
- Cannot set Determiner of CO to department/organization [#2915]
- Combination view is broken on Browse nomenclature [#2952]
- Matrix row coder button in Observation matrix dashboard task redirect to a wrong OTU in Image Matrix task [#2956]
- Depiction radials are not working in Image matrix task [#2954]

[#2960]: https://github.com/SpeciesFileGroup/taxonworks/issues/2960
[#2947]: https://github.com/SpeciesFileGroup/taxonworks/issues/2947
[#2957]: https://github.com/SpeciesFileGroup/taxonworks/issues/2957
[#2915]: https://github.com/SpeciesFileGroup/taxonworks/issues/2915
[#2952]: https://github.com/SpeciesFileGroup/taxonworks/issues/2952
[#2954]: https://github.com/SpeciesFileGroup/taxonworks/issues/2954

## [0.24.3] - 2022-04-28

### Added

- DwC export includes `occurrenceStatus` [#2935]
- Tag panel for images in New images task [#2919]
- Repository section for Collection object match task [#2918]
- Preparations section for CO Match task [#2930]
- Match collection object button in Filter collection object [#2917]
- Lock button for By section in New extract task [#2926]
- With preparation facet in Filter collection objects [#2937]

### Changed

- Improved(?) behaviour of Extract autocomplete [#2923]
- New BiBTeX based Sources match and/or create Serials for some types [#2719]
- Improvements for taxon determinations in comprehensive task
- Observation Matrix CSV dump uses full object labels [#2912]
- Allow multiple origin relationships in New extract task [#2928]
- Enable biocuration buttons only for the current collection object in comprehensive task [#2946]
- Updated ruby gems

### Fixed

- Display full citation in image viewer [#2857]
- Extract filter OTU id match not matching determinations [#2925]
- Improve observation matrix row label handling [#2902]
- Showing related data for Descriptor broken [#2934]
- Collection object label is not updated after saving determinations in comprehensive task [#2899]
- Label form is not updated after loading a collecting event in Comprehensive task [#2898]
- Preferred catalog number for collection objects using first created rather than top of the list (also fixes wrong `otherCatalogNumbers` in DwC export) [#2904]
- Missing not fixable error message for automatically soft validations [#2877]
- Recent lists on Data have broken flex CSS [#2920]
- Generating label from collecting event with verbatim trip identifier duplicates tripcode [#2921]
- Leaflet map does not center the view on shapes
- Programming typos affecting error handling in some batch loaders
- PDF reading causing software crash with some PDF documents (e.g. encrypted and/or having unsupported features)
- "virtual" spelled "virutal" [#2938]
- Protocols should not display origin [#2927]
- Determination lock not working for "Add to container" in Comprehensive task [#2943]
- Role types table in uniquify people renders poorly when "show found people" or "show match people" enabled [#2894]
- Syntax error during code generating synonyms and descendants for catalogs

[#2719]: https://github.com/SpeciesFileGroup/taxonworks/issues/2719
[#2857]: https://github.com/SpeciesFileGroup/taxonworks/issues/2857
[#2857]: https://github.com/SpeciesFileGroup/taxonworks/issues/2857
[#2877]: https://github.com/SpeciesFileGroup/taxonworks/issues/2877
[#2894]: https://github.com/SpeciesFileGroup/taxonworks/issues/2894
[#2898]: https://github.com/SpeciesFileGroup/taxonworks/issues/2898
[#2899]: https://github.com/SpeciesFileGroup/taxonworks/issues/2899
[#2902]: https://github.com/SpeciesFileGroup/taxonworks/issues/2902
[#2904]: https://github.com/SpeciesFileGroup/taxonworks/issues/2904
[#2912]: https://github.com/SpeciesFileGroup/taxonworks/issues/2912
[#2917]: https://github.com/SpeciesFileGroup/taxonworks/issues/2917
[#2918]: https://github.com/SpeciesFileGroup/taxonworks/issues/2918
[#2919]: https://github.com/SpeciesFileGroup/taxonworks/issues/2919
[#2920]: https://github.com/SpeciesFileGroup/taxonworks/issues/2920
[#2921]: https://github.com/SpeciesFileGroup/taxonworks/issues/2921
[#2923]: https://github.com/SpeciesFileGroup/taxonworks/issues/2923
[#2925]: https://github.com/SpeciesFileGroup/taxonworks/issues/2925
[#2926]: https://github.com/SpeciesFileGroup/taxonworks/issues/2926
[#2927]: https://github.com/SpeciesFileGroup/taxonworks/issues/2927
[#2928]: https://github.com/SpeciesFileGroup/taxonworks/issues/2928
[#2930]: https://github.com/SpeciesFileGroup/taxonworks/issues/2930
[#2934]: https://github.com/SpeciesFileGroup/taxonworks/issues/2934
[#2935]: https://github.com/SpeciesFileGroup/taxonworks/issues/2935
[#2937]: https://github.com/SpeciesFileGroup/taxonworks/issues/2937
[#2938]: https://github.com/SpeciesFileGroup/taxonworks/issues/2938
[#2943]: https://github.com/SpeciesFileGroup/taxonworks/issues/2943

## [0.24.2] - 2022-04-15

### Added

- New units mg, µg, ng, ml, µl, nl, ng/µl, Ratio (for Descriptor, etc.) [#2887]
- Project activity report includes community data (but not scoped to project) [#2893]
- Protocols for Observations [#2889]
- Increment tripcode in New collecting event task [#2441]
- Now and today buttons for time/date made [#2888]
- Radial navigator to New extract task [#2885]

### Changed

- Refactor Uniquify People task. Added improvements [#2858]
- Removed PDF viewer broad channel event
- Updated Ruby gems

### Fixed

- Extract -> show rendering raising [#2886]
- People being set as invalid during automatic activity updates
- Project activity session report shows hours properly [#2878]
- xAxis category ordering of Project activity [#2891]
- Sometimes it's not possible move images from one cell to another in Image matrix task [#2874]
- Uniquify people task are not merging all selected match people [#2892]
- Media observations are not displayed after creating them using drag and drop box in Matrix row coder task. [#2880]
- New extract task loads incorrect repository for existing extracts [#2883]
- Extract edit link in New observation matrix task [#2896]
- Incorrect matrix list is displayed on Observation matrix slice in Radial object [#2901]
- Pages label is not displayed in citation form in comprehensive task [#2903]

[#2886]: https://github.com/SpeciesFileGroup/taxonworks/issues/2886
[#2887]: https://github.com/SpeciesFileGroup/taxonworks/issues/2887
[#2878]: https://github.com/SpeciesFileGroup/taxonworks/issues/2878
[#2891]: https://github.com/SpeciesFileGroup/taxonworks/issues/2891
[#2893]: https://github.com/SpeciesFileGroup/taxonworks/issues/2893
[#2889]: https://github.com/SpeciesFileGroup/taxonworks/issues/2889
[#2441]: https://github.com/SpeciesFileGroup/taxonworks/issues/2441
[#2858]: https://github.com/SpeciesFileGroup/taxonworks/issues/2858
[#2883]: https://github.com/SpeciesFileGroup/taxonworks/issues/2883
[#2885]: https://github.com/SpeciesFileGroup/taxonworks/issues/2885
[#2888]: https://github.com/SpeciesFileGroup/taxonworks/issues/2888
[#2892]: https://github.com/SpeciesFileGroup/taxonworks/issues/2892
[#2896]: https://github.com/SpeciesFileGroup/taxonworks/issues/2896
[#2901]: https://github.com/SpeciesFileGroup/taxonworks/issues/2901
[#2903]: https://github.com/SpeciesFileGroup/taxonworks/issues/2903

## [0.24.1] - 2022-04-04

### Changed

- Time ranges for `eventTime` in DwC occurrences importer are now supported
- Updated Ruby gems

### Fixed

- Observation matrix row filter generalized to work for all observation object types [#2873]

[#2873]: https://github.com/SpeciesFileGroup/taxonworks/issues/2873

## [0.24.0] - 2022-03-31

### Added

- Collection object `current_repository_id` and interface toggle [#2866]
- Use Namespace as DwC `collectionCode` [#2726]
- Notes on CollectionObject export to DwC `occurrenceRemarks` [#2850]
- Link to comprehensive digitization collection object via `?dwc_occurrence_object_id=123` [#2851]
- Project user activity report task [#50] [#1062]
- 'Inferred combination' to Browse taxon name header, when required [#2836]
- Extract autocomplete
- Matrix row coder supports mutiple Quantitative and Sample observations per "cell"
- Extracts are observable [#2037]
- Download observation matrix descriptors as text
- Download observation matrix observations in .tab format
- Observations have `made_year|month|day|time` attributes
- Qualitative descriptor batch loader (Data->Descriptors->Batch load) [#1831] (in part)
- Modal depictions for all descriptors in Matrix row coder [#2847]
- New georeference type for user-supplied points [#2843]
- Extract rows in New observation matrix
- Depiction modal for all descriptors in Interactive key
- Link CollectionObject batch load to DwCA importer [#2868]

### Changed

- Administration activity report
- DwC export uses a "sorted" column order [#2844]
- Observations now are polymorphic [#2037]
- Replace autocompletes by smart selectors in Common Name form on OTU radial [#2840]
- Updated Ruby gems
- DwC importer sex mapped changed to prioritize `http://rs.tdwg.org/dwc/terms/sex` DwC URI and also create sex biocuration group with such URI if none exist.
- Taxon name label for original combination label in Citations by source task.
- Add separate scrollbars to row and column tables in New observation matrix task [#2799]
- Change form fields order in OTU radial - Biological associations
- Updated ruby gems
- Close modal after select a status in New taxon name
- Escape new additional pseudo-LaTeX encodings from BibTex data

### Fixed

- DwC georeferencedProtocol references Protocols properly [#2842]
- DwC georeferencedBy references Georeferencers properly [#2846]
- Administration activity report raising [#2864]
- OTUs and collection objects batch-loaders failing to initialize due to Ruby syntax error
- Sqed depictions crash on cache update when no processing results are available
- Asserted distributions on OTU radial is_absent no longer locks [#2848]
- After saving an area with 'is absent' flag, the form stays locked in OTU radial Asserted distribution
- Uniquify people roles list is missing role_object_tag [#2853]
- Large list of taxon names are not loaded in Citations by source
- Missing source_id parameter in Citation by source link on New asserted distribution and Browse OTU
- New CO assigns a wrong Identifier type in New collecting event task [#2862]

[#2866]: https://github.com/SpeciesFileGroup/taxonworks/issues/2866
[#2726]: https://github.com/SpeciesFileGroup/taxonworks/issues/2726
[#2850]: https://github.com/SpeciesFileGroup/taxonworks/pull/2850
[#2851]: https://github.com/SpeciesFileGroup/taxonworks/pull/2851
[#2868]: https://github.com/SpeciesFileGroup/taxonworks/pull/2868
[#2842]: https://github.com/SpeciesFileGroup/taxonworks/pull/2842
[#2846]: https://github.com/SpeciesFileGroup/taxonworks/pull/2846
[#50]: https://github.com/SpeciesFileGroup/taxonworks/pull/50
[#1062]: https://github.com/SpeciesFileGroup/taxonworks/pull/1062
[#2864]: https://github.com/SpeciesFileGroup/taxonworks/pull/2864
[#2844]: https://github.com/SpeciesFileGroup/taxonworks/pull/2844
[#2836]: https://github.com/SpeciesFileGroup/taxonworks/pull/2836
[#2037]: https://github.com/SpeciesFileGroup/taxonworks/pull/2037
[#1831]: https://github.com/SpeciesFileGroup/taxonworks/pull/1831
[#2799]: https://github.com/SpeciesFileGroup/taxonworks/pull/2799
[#2840]: https://github.com/SpeciesFileGroup/taxonworks/pull/2840
[#2843]: https://github.com/SpeciesFileGroup/taxonworks/pull/2843
[#2847]: https://github.com/SpeciesFileGroup/taxonworks/pull/2847
[#2848]: https://github.com/SpeciesFileGroup/taxonworks/pull/2848
[#2853]: https://github.com/SpeciesFileGroup/taxonworks/pull/2853
[#2862]: https://github.com/SpeciesFileGroup/taxonworks/pull/2862

## [0.23.1] - 2022-03-01

### Added

- Qualitative descriptor modal in matrix row coder [#2763]
- Pin button for organization in attribution annotator [#2551]
- Image inventory/filter endpoint for OTUs `/api/v1/otus/123/inventory/images` [#2656]
- Option to error records if `typeStatus` is unprocessable in DwC occurrences importer [#2829]
- Several taxon name classifications in DwC checklist importer [#2732]

### Changed

- Allow matching protonyms in DwC occurrences importer even on cases where the imported classification is a subset of the existing one [#2740]
- Updated Ruby gems
- Copying observations from object to object also copies their depictions [#2823]

### Fixed

- Not all year metadata automatically updated Person active metadata [#2854]
- DwC importer looking up collecting events outside the scope of the current project
- Missing names in hierarchy tree on Browse nomenclature task [#2827]
- DwC importer finding names by original combination without project scope [#2828]
- DwC export month field exporting day value rather than month [#2835]
- Use unofficial serrano repo to fix problems with citeproc-json responses
- DwC Occurrence Importer settings modal lags on open when many namespaces set [#2834]
- Destroying last Depiction for Observation::Media destroys Observations [#2269]
- Allowing to use same Namespace short name with different casing (e.g. 'alpha', 'Alpha')

[#2854]: https://github.com/SpeciesFileGroup/taxonworks/issues/2854
[#2823]: https://github.com/SpeciesFileGroup/taxonworks/issues/2823
[#2269]: https://github.com/SpeciesFileGroup/taxonworks/issues/2269
[#2656]: https://github.com/SpeciesFileGroup/taxonworks/issues/2656
[#2551]: https://github.com/SpeciesFileGroup/taxonworks/issues/2551
[#2732]: https://github.com/SpeciesFileGroup/taxonworks/pull/2732
[#2740]: https://github.com/SpeciesFileGroup/taxonworks/pull/2740
[#2763]: https://github.com/SpeciesFileGroup/taxonworks/issues/2763
[#2827]: https://github.com/SpeciesFileGroup/taxonworks/issues/2827
[#2828]: https://github.com/SpeciesFileGroup/taxonworks/pull/2828
[#2829]: https://github.com/SpeciesFileGroup/taxonworks/pull/2829
[#2834]: https://github.com/SpeciesFileGroup/taxonworks/pull/2834
[#2835]: https://github.com/SpeciesFileGroup/taxonworks/pull/2835

## [0.23.0] - 2022-02-18

### Added

- Extract Filter [#2270]
- Protocol facets for filters, currently on Extract filter
- OTU descendants API endpoint `.../otus/123/inventory/descendants` [#2791]
- Download SVG button in object graph task [#2804]
- Rake task to generate docs.taxonworks.org Data documentation [#2352]
- Confirmation window for delete documentation in radial annotator [#2820]
- Drag and drop to sort predicates in project preferences [#2821]
- Endpoints for observation matrix row and column labels [#2800]
- Matrix row navigation in Matrix row coder [#2800]
- Download enabled for controlled vocabulary terms [#2809]
- Type materials metadata extension for /api/v1/otus

### Changed

- Tweaked how Extracts are displayed in various views
- Browse nomenclature task was renamed to Browse nomenclature and classifications [#2638]
- Add origin citations for taxon name relationships/classifications, renames route [#2790]
- Add Download customization [#2748]
- Show Images section in Browse OTU for GenusGroup [#2786]
- User facet: `Now` button sets end date in Filter interfaces [#2788]
- Changes content and layout ouf hierarchy navigator in Browse nomenclature task [#2797]
- Scroll tables in New observation matrix task [#2799]
- Updated Ruby gems
- Replace autocomplete with OTU picker in biological associations form in radial object

### Fixed

- Author string for incorrect original spelling [#2743]
- Type species section doesn't work in new taxon name [#2785]
- Missing Variety and Form ranks in original combination section for ICZN in New taxon name task [#2795]
- Check if current identifier is the same as current in comprehensive task [#2550]
- Comprehensive digitization - entering '0' in total breaks the interface [#2807]
- Download link doesn't work in data list view
- Edit in Browse collecting event [#2814]
- DwC importer is more robust to invalid taxon names

[#2743]: https://github.com/SpeciesFileGroup/taxonworks/issues/2743
[#2638]: https://github.com/SpeciesFileGroup/taxonworks/issues/2638
[#2270]: https://github.com/SpeciesFileGroup/taxonworks/issues/2270
[#2800]: https://github.com/SpeciesFileGroup/taxonworks/issues/2800
[#2352]: https://github.com/SpeciesFileGroup/taxonworks/issues/2552
[#2550]: https://github.com/SpeciesFileGroup/taxonworks/issues/2550
[#2790]: https://github.com/SpeciesFileGroup/taxonworks/issues/2790
[#2748]: https://github.com/SpeciesFileGroup/taxonworks/issues/2748
[#2791]: https://github.com/SpeciesFileGroup/taxonworks/issues/2791
[#2785]: https://github.com/SpeciesFileGroup/taxonworks/issues/2785
[#2786]: https://github.com/SpeciesFileGroup/taxonworks/issues/2786
[#2788]: https://github.com/SpeciesFileGroup/taxonworks/issues/2788
[#2795]: https://github.com/SpeciesFileGroup/taxonworks/issues/2795
[#2797]: https://github.com/SpeciesFileGroup/taxonworks/issues/2797
[#2804]: https://github.com/SpeciesFileGroup/taxonworks/issues/2804
[#2807]: https://github.com/SpeciesFileGroup/taxonworks/issues/2807
[#2809]: https://github.com/SpeciesFileGroup/taxonworks/issues/2809
[#2814]: https://github.com/SpeciesFileGroup/taxonworks/issues/2814
[#2799]: https://github.com/SpeciesFileGroup/taxonworks/issues/2799
[#2800]: https://github.com/SpeciesFileGroup/taxonworks/issues/2800
[#2820]: https://github.com/SpeciesFileGroup/taxonworks/issues/2820
[#2821]: https://github.com/SpeciesFileGroup/taxonworks/issues/2821

## [0.22.7] - 2022-01-26

### Added

- Add more date (redundant) fields to DwC export [#2780]
- Import and export custom label style in print label task
- Attributions in Filter images [#2639]
- People, role, images stats to `/api/v1/stats`
- `basisOfRecord` in DwC exports can be `FossilSpecimen` via biocuration
- Classification section for Combination in New taxon name (botanical nomenclature support) [#2681]
- API `/api/v1/otus/:id` includes `&extend[]` for `parents`

### Changed

- New interface for biocuration groups and classes
- DwCA export is _much_ faster
- CSV export optimized
- `basisOfRecord` now maps as `http://rs.tdwg.org/dwc/terms/FossilSpecimen` biocuration classification in DwC occurrences importer.
- Updated ruby gems
- Updated js packages
- cached_is_valid is now used in interfaces to show if a taxon is valid or invalid
- Refactor Manage biocuration classes and groups task [#83]

### Fixed

- `occurrenceID` missing from DwC exports. [#2766]
- Cloning columns from matrices sometimes partially failed [#2772]
- Missing `Custom style` button in Print label task [#2764]
- Missing valid/invalid/combination mark in citation by source task [#2760]
- Missing observation matrices in copy columns/rows from another matrix in New observation matrix task [#2753]
- Handing of family names starting with `O'` being recognized as given names [#2747]
- Error 500 deleting a biocuration term [#2181]
- Uniquify people task shows "0" in used column and no roles [#2769]

[#83]: https://github.com/SpeciesFileGroup/taxonworks/issues/83
[#2181]: https://github.com/SpeciesFileGroup/taxonworks/issues/2181
[#2780]: https://github.com/SpeciesFileGroup/taxonworks/issues/2780
[#2766]: https://github.com/SpeciesFileGroup/taxonworks/issues/2766
[#2772]: https://github.com/SpeciesFileGroup/taxonworks/pull/2772
[#2639]: https://github.com/SpeciesFileGroup/taxonworks/pull/2639
[#2681]: https://github.com/SpeciesFileGroup/taxonworks/issues/2681
[#2747]: https://github.com/SpeciesFileGroup/taxonworks/issues/2747
[#2753]: https://github.com/SpeciesFileGroup/taxonworks/issues/2753
[#2760]: https://github.com/SpeciesFileGroup/taxonworks/issues/2760
[#2764]: https://github.com/SpeciesFileGroup/taxonworks/issues/2764
[#2769]: https://github.com/SpeciesFileGroup/taxonworks/issues/2769

## [0.22.6] - 2022-01-10

### Added

- Option to select all and quick tag in Filter image task [#2744]

### Changed

- Perform georeferences caching in background for faster DwC occurrences import [#2741]
- Permit use of Ruby 3.1
- Updated Ruby gems.
- DwC occurrences importer: When matching protonyms also consider their alternate gender names if there are no matches by exact name. [#2738]
- Allow import of specimens with empty `catalogNumber` even when `institutionCode` and/or `collectionCode` are set.

### Fixed

- Several batch loaders not working due to syntax incompatibility with currently used Ruby version. [#2739]

[#2739]: https://github.com/SpeciesFileGroup/taxonworks/pull/2739
[#2741]: https://github.com/SpeciesFileGroup/taxonworks/pull/2741
[#2738]: https://github.com/SpeciesFileGroup/taxonworks/issues/2738
[#2744]: https://github.com/SpeciesFileGroup/taxonworks/issues/2744

## [0.22.5] - 2021-12-22

### Fixed

- Fixed "eye" validation crash when activated in Browse Nomenclature task [#2736]

[#2736]: https://github.com/SpeciesFileGroup/taxonworks/issues/2736

## [0.22.4] - 2021-12-21

### Added

- Add `reset filters` button in DwC import task [#2730]

### Changed

- Add space on navbar in New taxon name [#2701]
- Updated ruby gems and node packages.
- Tabindex in model view

### Fixed

- Overdue loan date time ago [#2712]
- Descriptor character state destroy raising [#2713]
- Loan items status not updatable (also new specs) [#2714]
- Collecting event filter `depictions` facet [#2720]
- Taxonifi wrapper init was broken
- Character order selector sends null value on blank selection [#2707]
- Interactive keys is loading two matrices on autocomplete search [#2706]
- `Select observation matrix` is not displaying all observation matrices [#2708]
- Crashing when attempting to download DwC results from Filter Collection Objects task with 'Treat geographic areas as spatial' set.
- Stats response contains `projects` count when project token is set.
- Menu options broken when right-click on matrices in Observation matrix hub [#2716]
- Copy rows from matrix in New observation matrix
- GnFinder playground incompatibility with current GnFinder API
- DwC checklist importer issue with synonyms have wrong rank [#2715]
- Scientific name not cached properly when the taxon name is classified as part of speech [#2721]
- Depictions dropzone tries to create Depictions before saving collecting event
- Clipboard is not releasing key combination when the user clicks outside the window and release keys [#2724]
- Removed `destroy!` pattern from various controllers
- Unable to create loan items in Collection object match task [#2731]
- DwC import search criteria is missing when search box is reopen [#2729]
- Unable to download CoLDP exports
- Otu facet in Filter image task

[#2712]: https://github.com/SpeciesFileGroup/taxonworks/issues/2712
[#2713]: https://github.com/SpeciesFileGroup/taxonworks/issues/2713
[#2714]: https://github.com/SpeciesFileGroup/taxonworks/issues/2714
[#2720]: https://github.com/SpeciesFileGroup/taxonworks/issues/2720
[#2701]: https://github.com/SpeciesFileGroup/taxonworks/issues/2701
[#2706]: https://github.com/SpeciesFileGroup/taxonworks/issues/2706
[#2707]: https://github.com/SpeciesFileGroup/taxonworks/issues/2707
[#2708]: https://github.com/SpeciesFileGroup/taxonworks/issues/2708
[#2715]: https://github.com/SpeciesFileGroup/taxonworks/pull/2715
[#2716]: https://github.com/SpeciesFileGroup/taxonworks/issues/2716
[#2721]: https://github.com/SpeciesFileGroup/taxonworks/pull/2721
[#2724]: https://github.com/SpeciesFileGroup/taxonworks/pull/2724
[#2729]: https://github.com/SpeciesFileGroup/taxonworks/pull/2729
[#2730]: https://github.com/SpeciesFileGroup/taxonworks/issues/2730
[#2731]: https://github.com/SpeciesFileGroup/taxonworks/issues/2731

## [0.22.3] - 2021-12-03

### Added

- Ability to inject links into Content via hot-key searching [#1674]

### Changed

- Upgraded to Postgres 12 in Docker Compose development environment. Postgres 10 container and volume are still present to allow for automatic data migration.

### Fixed

- Identifier form elements on SQED breakdown [#2700]

[#2700]: https://github.com/SpeciesFileGroup/taxonworks/issues/2700
[#1674]: https://github.com/SpeciesFileGroup/taxonworks/issues/1674

## [0.22.2] - 2021-12-02

### Changed

- Upped from 40 to 500 the cutoff point at which updating a collecing event will trigger a DwcOccurrence rebuild
- Added a `url_base` option when rendering metadata partial

### Fixed

- Author by first letter (/people.json) [2697]
- Loan recipient helper methods were confused with loan helper methods
- Subsequent combination link in new taxon name task [#2695]
- Unable to create tags in batches due to Ruby 3 syntax changes.
- Observation matrices crashing due to response pagination bug.
- Unable to create namespaces due to debug code accidentally added.

[#2697]: https://github.com/SpeciesFileGroup/taxonworks/issues/2697
[#2695]: https://github.com/SpeciesFileGroup/taxonworks/issues/2695

## [0.22.1] - 2021-12-01

### Added

- Georeferences can link to Protocols

### Changed

- API -added extend character_state option to /observations

### Fixed

- Updated reference string for 'classified as' relationship in Browse nomenclature
- Custom attributes are not cleared on new record [#2692]
- API - /api/v1/observation_matrices with no params failed
- Asserted distribution link wasn't HTML safe

[#2692]: https://github.com/SpeciesFileGroup/taxonworks/issues/2692

## [0.22.0] - 2021-11-30

### Added

- Indecies on taxon name hierarchies table
- Batch create user admin task [#2680]
- Radial navigation in loan task
- `is_gift` boolean to Loan
- Loan item notes, type status, and recipient form layout improvements [#2657]
- Recipient form link in Edit loan task
- Gift checkbox in Loan task
- API routes for data attributes via `/api/v1/data_attributes` [#2366]
- API routes for observation matrices via `/api/v1/observation_matrices`
- API route "status" for taxon names `/taxon_names/api/v1/123/status` [#2243]
- API route "activity" for recent records/project `/api/v1/activity?project_token=123&past_days=9` [#2207]
- Indecies for updated_at on some large models
- Observation matrix query filter (minimal)
- Add download table button in DwC Importer
- Confidence button on subsequent combination in New taxon name task
- Create and new button in New descriptor task [#2594]
- Content text is cropped on edit in OTU radial [#2676]
- Diagnosis status in matrix row coder [#2674]
- Layout preferences in comprehensive task [#2673]
- API `/api/v1/collection_objects` includes &extend[] for `dwc_fields` and `type_material`
- API `/api/v1/taxon_names/123/status` endpoint for human readable taxon name data and metadata (in part [#2665])
- `is_virtual` option to Namespace

### Changed

- Upgraded to Ruby 3.0.2
- OTUs can be loaned 2x [#2648]
- Upgraded gems
- `/collection_objects.json` response uses `&extend[]=dwc_fields` to return DwC fields; includes metadata
- Removed a loan item status 'Loaned on' (it's inferrred)
- Replaced Webrick with Puma (developers-only change)
- Improved loan autocomplete metadata [#2485]
- API observation responses are now isolated from internal
- DwC occurrences importer now accepts `|`, `:`, `;` and `,` as separators for `higherClassification`.
- Restrict subsequent combination fields for genus and subgenus. [#2677]
- Moved matrix autocomplete into `Include in matrix` section in New descriptor task [#2685]

### Fixed

- Update Source autocomplete [#2693]
- Containerized specimens export their identifier to DwC
- Biological association objects could be destroyed when referenced in biological association
- Reordering matrices by nomenclature when some rows have none
- Tag facet bug affecting all filters but Source [#2678]
- View errors on rows with no metadata in DwC importer
- Scrollbar in alternate values annotator [#2651]
- Missing data on response in citations annotator [#2653]
- Missing author and year in taxon name on Citation by source [#2650]
- Duplicate combinations in subsequent combination on New taxon name [#2654]
- Missing documents in source filter [#2661]
- Clonning source does not clean the doccumentation section [#2663]
- Extra scrollbar in asserted distributions annotator [#2662]
- The citations annotator sometimes displays a created citations that are not part of the object
- Move synonyms section not visible [#2670]
- Collecting Event collectors are not loaded when CE is selected using smart selector in Comprehensive task [#2669]
- Genus descriptor interface
- Free text character not saved if pasted from clipboard in Matrix Row Coder [#2672]
- DwC importer crashing on invalid nomenclatural code
- DwC exporter swapped `decimalLatitude`/`decimalLongitude`
- Error in Filter Collecting Event task when filtering by attributes that are stored as numbers in database
- `Set as current` button it isn't working when taxon parent is root on Subsequent combination [#2688]
- DwC checklist importing: original combination having wrong genus in some cases [#2684]

[#2286]: https://github.com/SpeciesFileGroup/taxonworks/issues/2286
[#2666]: https://github.com/SpeciesFileGroup/taxonworks/issues/2665
[#2665]: https://github.com/SpeciesFileGroup/taxonworks/issues/2665
[#2680]: https://github.com/SpeciesFileGroup/taxonworks/issues/2680
[#2678]: https://github.com/SpeciesFileGroup/taxonworks/issues/2678
[#2207]: https://github.com/SpeciesFileGroup/taxonworks/issues/2207
[#2243]: https://github.com/SpeciesFileGroup/taxonworks/issues/2243
[#2366]: https://github.com/SpeciesFileGroup/taxonworks/issues/2366
[#2485]: https://github.com/SpeciesFileGroup/taxonworks/issues/2485
[#2594]: https://github.com/SpeciesFileGroup/taxonworks/issues/2594
[#2648]: https://github.com/SpeciesFileGroup/taxonworks/issues/2648
[#2657]: https://github.com/SpeciesFileGroup/taxonworks/issues/2657
[#2650]: https://github.com/SpeciesFileGroup/taxonworks/issues/2650
[#2651]: https://github.com/SpeciesFileGroup/taxonworks/issues/2651
[#2653]: https://github.com/SpeciesFileGroup/taxonworks/issues/2653
[#2654]: https://github.com/SpeciesFileGroup/taxonworks/issues/2654
[#2661]: https://github.com/SpeciesFileGroup/taxonworks/issues/2661
[#2662]: https://github.com/SpeciesFileGroup/taxonworks/issues/2662
[#2663]: https://github.com/SpeciesFileGroup/taxonworks/issues/2663
[#2669]: https://github.com/SpeciesFileGroup/taxonworks/issues/2669
[#2670]: https://github.com/SpeciesFileGroup/taxonworks/issues/2670
[#2672]: https://github.com/SpeciesFileGroup/taxonworks/issues/2672
[#2673]: https://github.com/SpeciesFileGroup/taxonworks/issues/2673
[#2674]: https://github.com/SpeciesFileGroup/taxonworks/issues/2674
[#2676]: https://github.com/SpeciesFileGroup/taxonworks/issues/2676
[#2677]: https://github.com/SpeciesFileGroup/taxonworks/issues/2677
[#2684]: https://github.com/SpeciesFileGroup/taxonworks/pull/2684
[#2685]: https://github.com/SpeciesFileGroup/taxonworks/issues/2685
[#2688]: https://github.com/SpeciesFileGroup/taxonworks/issues/2688

## [0.21.3] - 2021-11-12

### Changed

- Loan addresses don't strip line-endings, and display in form [#2641]
- Replace radial navigator icon [#2645]
- Update smart selector tab selected on refresh

### Fixed

- Loan id facet [#2632]
- Roles in Image viewer
- Missing roles after trigger page autosave in new taxon name [#2631]
- Tag smart selector in new image task

[#2632]: https://github.com/SpeciesFileGroup/taxonworks/issues/2632
[#2631]: https://github.com/SpeciesFileGroup/taxonworks/issues/2631
[#2641]: https://github.com/SpeciesFileGroup/taxonworks/issues/2641
[#2645]: https://github.com/SpeciesFileGroup/taxonworks/issues/2645

## [0.21.2] - 2021-11-11

### Added

- Support for DwC terms on body of water depth [#2628]
- Filter Collection Objects by a specific Loan [#2632]

### Changed

- Updated ruby gems.

### Fixed

- Containerized specimens display catalog number in tag correctly [#2623]
- Improved CrossRef parsing for a new source [#997] [#2620]
- Container label shows catalog number for loan items [#1275]
- Determiners are not saved after lock the list in comprehensive form [#2626]
- Wrong rank for original combinations in DwC checklist importer [#2621]
- No longer exposing exception data for _failed_ records (not to be confused with _errored_) in DwC importer.
- Smart selector is not working in Browse Annotations
- Biological associations in OTU radial [#2630]
- Fix citations on asserted distribution list in OTU radial [#2629]
- Subsequent combinations are not scoped [#2634]
- Missing scroll in alternate value annotator [#2635]
- Smart selectors are not refreshing in New source [#2636]
- Radial navigation doesn't work on source in New taxon name task [#2633]
- Determiner is not selectable on Grid Digitizer after "Create and new" [#2637]
- DwC Dashboard data version counts correct now [#2627]
- Common statuses are not displayed in New taxon name task [#2642]
- Nomenclature and OTU (biology) display the same thing on Browse OTU page [#2644]
- New combination task hangs editing a combination [#2646]

[#2623]: https://github.com/SpeciesFileGroup/taxonworks/issues/2623
[#2627]: https://github.com/SpeciesFileGroup/taxonworks/issues/2627
[#1275]: https://github.com/SpeciesFileGroup/taxonworks/issues/1275
[#2628]: https://github.com/SpeciesFileGroup/taxonworks/issues/2628
[#2626]: https://github.com/SpeciesFileGroup/taxonworks/issues/2626
[#2621]: https://github.com/SpeciesFileGroup/taxonworks/pull/2621
[#2629]: https://github.com/SpeciesFileGroup/taxonworks/issues/2629
[#2630]: https://github.com/SpeciesFileGroup/taxonworks/issues/2630
[#2633]: https://github.com/SpeciesFileGroup/taxonworks/issues/2633
[#2634]: https://github.com/SpeciesFileGroup/taxonworks/issues/2634
[#2635]: https://github.com/SpeciesFileGroup/taxonworks/issues/2635
[#2636]: https://github.com/SpeciesFileGroup/taxonworks/issues/2636
[#2637]: https://github.com/SpeciesFileGroup/taxonworks/issues/2637
[#2642]: https://github.com/SpeciesFileGroup/taxonworks/issues/2642
[#2644]: https://github.com/SpeciesFileGroup/taxonworks/issues/2644
[#2646]: https://github.com/SpeciesFileGroup/taxonworks/issues/2646

## [0.21.1] - 2021-11-05

### Fixed

- Citations in image viewer

## [0.21.0] - 2021-11-04

### Added

- Added new handling for plant name author_string.
- Added new `Combination` section to handle historical protonym combination.
- Add new task 'Object graph', visualize and navigate your Things via a force-directed-graph (network) [#2587]
- New combination editing, including support for multiple authors in plant names [#666] [#2407]
- Add new global identifier class for glbio repositories
- New parameters for fine-tuning the API responses, `&extend[]=` and `&embed[]` [#2531]
- Parameter value `origin_citation` via `&extend[]=` to all basic GET `/object(/:id)` requests [#2531]
- Parameter value `pinboard_item` via `&extend[]=` to all basic GET `/object(/:id)` requests [#2531]
- Parameter value `citations` via `&extend[]=` to all basic GET `/object/:id` requests [#2531]
- Parameter values `roles` and `documents` via `&extend[]=` to `/sources(/:id).json` [#2531]
- Parameter values `protonyms` and `placement` via `&extend[]=` to `/combinations(/:id).json [#2531]
- Parameter values `parent`, `otus`, `roles`, `ancestor_ids`, `children`, `type_taxon_name_relationship` via `&extend[]=` to `/taxon_names(/:id).json` [#2531]
- Parameter values `level_names`, `geographic_area_type`, `parent` via `&extend[]=` and `shape` via `&embed[]=` to `/geographic_areas(/:id).json` [#2531]
- Parameter value `subject`, `object`, `biological_relationship`, `family_names` via `&extend[]=` to `/biological_associations(/:id).json` [#2531]
- Parameter value `citation_object`, `citation_topics`, `source`, `target_document` via `&extend[]=` to `/citations(/:id).json` [#2531]
- API route `/taxon_names/parse?query_string=Aus bus` for resolving names to Protonyms
- Parameter value `roles` via `&extend[]=` to `/collecting_events(/:id).json` [#2531]
- Param to isolate TaxonName smart select to Protonym if optional
- Resize column in Filter tasks [#2606]
- Confirmation banner in 'Collection Object Match'

### Changed

- Added new DwcOccurrence date-version
- dwcSex and dwcStage are now referenced by BiocurationGroup [#2615]
- Improved autocomplete search for Serials, Sources and Repositories [#2612]
- Ordering of GeorgaphicArea autocomplete results. Used areas and areas with shapes are prioritized
- Basic (REST) endpoints send less information, use `&extend[]` and `&embed[]` to return more [#2531]
- Numerous tasks updated to use the new REST pattern
- Objects in basic show/index JSON endpoints are represented by their metadata, rather than all their attributes in many cases now [#2531]
- Metadata in extensions does not cascade and return metadata of metadata [#2531]
- JSON smart-selector data (`/sources/select_options`) includes base attributes, not metadata [#2531]
- Updated corresponding ap1/v1 endpoints to use the `&extend[]` pattern for `/otus`, `/taxon_names`, `/combinations`, `/sources`, `/citations` (in part) and `biological_associations` to match the new parameter values above
- API `/api/v1/biological_associations` uses metadata for related objects
- Optimized Source smart selection queries
- Added option in DwC importer to specific the dataset type (defaults to auto-detection).
- Replace autocomplete for smart selector in alternate values annotator [#2610]

### Fixed

- DwC recordedBy not referencing verbatim_collectors, only collectors [#2617]
- DwC recordedByID returning delimiter only records
- DwC decimalLatitude/Longitude incorrectly mapped [#2616]
- Citation style taxonworks.csl is updated [#2600]
- `collector_id` broken in CollecitonObject filter
- Failure when setting up namespaces in DwC importer with datasets having _unnamed_ columns
- Namespace settings are not cleared when unmatched and re-opened in DwC Import [#2586]
- ScientificNameAuthorship parsing issues in DwC importer [#2589]
- Author and editor roles are missing after save or create a source in New source task [#2607]
- Rank genus not being auto-detected when uninomial name in scientificName matches genus term value exactly
- Soft validation block is displayed when is empty in New source task [#2611]
- Clipboard shortcut hot-keys were broken
- Serial raises on failed destroy gracefully handled
- CrossRef assigns the wrong serial when journal is not present (partial) [#2620]

[#666]: https://github.com/SpeciesFileGroup/taxonworks/issues/666
[#2407]: https://github.com/SpeciesFileGroup/taxonworks/issues/2407
[#2612]: https://github.com/SpeciesFileGroup/taxonworks/issues/2612
[#2613]: https://github.com/SpeciesFileGroup/taxonworks/issues/2613
[#2615]: https://github.com/SpeciesFileGroup/taxonworks/issues/2615
[#2617]: https://github.com/SpeciesFileGroup/taxonworks/issues/2617
[#2616]: https://github.com/SpeciesFileGroup/taxonworks/issues/2616
[#2587]: https://github.com/SpeciesFileGroup/taxonworks/issues/2587
[#2531]: https://github.com/SpeciesFileGroup/taxonworks/issues/2531
[#2586]: https://github.com/SpeciesFileGroup/taxonworks/issues/2586
[#2589]: https://github.com/SpeciesFileGroup/taxonworks/issues/2589
[#2606]: https://github.com/SpeciesFileGroup/taxonworks/issues/2606
[#2608]: https://github.com/SpeciesFileGroup/taxonworks/issues/2608
[#2610]: https://github.com/SpeciesFileGroup/taxonworks/issues/2610
[#2611]: https://github.com/SpeciesFileGroup/taxonworks/issues/2611
[#2620]: https://github.com/SpeciesFileGroup/taxonworks/issues/2620

## [0.20.1] - 2021-10-15

### Added

- Added missing OTU soft_validation for protonym
- Added recent values on keywords
- Added Attribution attributes to `/images` API show responses
- API `/images` can return images by `image_file_fingerprint` (MD5), in addition to id

### Changed

- Updated author string for misspellings
- Removed footprintWKT from DwcOccurrence. It will be re-instated as optional in the future.
- Removed GeographicArea from consideration as a _georeference_ in DwcOccurrence
- Changed `associatedMedia` format, pointed it to
- Removed redundant 'Rebuild' button from Browse collection objects

### Fixed

- DwC Dashboard past links are properly scoped
- DwC Dashboard graphs show proper count ranges
- DwC archive no longer truncated at 10k records
- OccurrenceID was not being added to DwcOccurrence attributes in all cases [#2573]
- Observation matrix show expand was referencing the wrong id [#2540]
- Copy pasting into verbatim year with alphanumeric gives error even though numeric are all that are visible in New taxon name [#2577]
- Record doesn't sync/update the list in OTU quick forms [#2576]
- TIFF images are not visible in filter image task [#2575]
- Repository input shows value, when not set [#2574]
- Images don't load after expand depictions sections in comprehensive task
- DwC occurrences importer being too strict when checking against existing nomenclature [#2581]

[#2573]: https://github.com/SpeciesFileGroup/taxonworks/issues/2573
[#2540]: https://github.com/SpeciesFileGroup/taxonworks/issues/2540
[#2574]: https://github.com/SpeciesFileGroup/taxonworks/issues/2574
[#2575]: https://github.com/SpeciesFileGroup/taxonworks/issues/2575
[#2576]: https://github.com/SpeciesFileGroup/taxonworks/issues/2576
[#2577]: https://github.com/SpeciesFileGroup/taxonworks/issues/2577
[#2581]: https://github.com/SpeciesFileGroup/taxonworks/issues/2581

## [0.20.0] - 2021-10-12

### Added

- Task `DwC Import` for importing DwC Archive files
- Task `DwC Dashboard` facilitating DwCA download, metadata reporting, and "health" checks [#1467]
- Updated framework for producing and downloading DwC Archives (DwCA) [#1775] [#1303]
- Increased from 21 to 53 the number of fields referenced in the (DwCA) dump, including `identifiedByID` and `recordedByID` [#1269] [#1230]
- Auto-generation of UUIDs for instances that don't have global identifiers during DwcOccurrence record building [#2186]
- Wikidata (Q) and ORCiD support for people references in DwCA dumps
- Georeferences can have Confidences assigned to them [#1772]
- CSL style 'taxonworks.csl' used as the default style for displaying sources [#2517]
- Custom CSL citation support for reference formating (see styles at bottom of select format list). New .cls submitted via issue tracker and integrated to source.
- New .csl style 'world_chalcidoidea_book.csl"
- BibTeX fields support verbatim values using "{}" for fields otherwise processed in BibTeX sources (e.g. author)
- New specs for rendering Source citations
- `&extend[]` and `&embed[]` helper methods for REST responses [#2532]
- A new soft validation option to auto fix for objective synonym that must share the same type
- Add `Download`, `Full size` and `Radial navigation` buttons in Image viewer [#2423]
- Endpoint `/tasks/dwc/dashboard/index_versions` returns the dates at which DwcOccurrence indexing was modified. !! TODO: update date of merge.
- Endpoint `/dwc_occurrences/metadata`, for stats on the state of DwcOccurrence index
- Endpoint `/dwc_occurrencs/predicates` to return a list of Predicates used on CollectionObjects and CollectingEvents
- Endpoint `/dwc_occurrences/status` to check whether DwcOccurrence records are up-to-date
- Endpoint `/dwc_occurrences/collector_id_metadata` to check whether People referenced in DwcOccurences have GUIDs
- Task on Administration panel, "Reindex", with (temporary) options to re-index small blocks of DwcOccurrence records
- Button on CollectionObject filter to download filter result as DwC Archive [#1303]
- User can select a corresponding Person as their data representation (facilitates Identifiers for Users) [#1486]
- Centroid index on GeographicItem
- Field `total_records` on Download
- Index on polymorphic fields of DwcIndex (e.g. faster queries to CollectionObject)
- Index on `data_origin` for GeographicAreasGeographicItem
- Identifiers for AssertedDistributions
- Various relationships enabling the joining of DwcOccurrence directly to other classes of data (e.g. Georeferences)
- Isolated Georeference related utilities into their own module CollectingEvent::Georeference
- A Taxonomy module that caches classification values, used in CollectionObject, and Otu
- Methods to return when a record attribute was updated (e.g. verbatim_locality changed), and who did it for Papertrail including classes of data
- Methods to handle multiple classes of globally unique identifiers on DwcOccurrence records
- Pattern for isolating modules that aid DwC serialization per class of data
- Optimized `to_wkt` to quickly return well-known-text for geo-shapes (in part, [#2526])
- New subclass of UUID `Identifier::Global::Uuid::TaxonworksDwcOccurrence`
- Clarified, via`georeferenceSources` and `georeferenceProtocol` why there are many decimal points in DwC latitude/longitude referencing fields [#915] [#1175]
- Option to rebuild single DwcOccurrence record for CollectionObject [#2563]
- Ability to show observation matrices > 10k cells in size [#1790]
- Rake task to rebuild source cached
- Add download and radial buttons for image viewer in filter image

### Fixed

- Downloading formatted sources with mixed types (BibTeX/Verbatim) failed [#2512]
- Collection object filter type material param
- Taxon name filter type metadata param fails [#2511]
- Cloning a collecting event fails [#2533]
- Modified recordedBy fields to only reference collector [#2567] [#2558]
- Many TDWG gazeteer references will now be properly categorized into state and country labels [#2542]
- In Browse Nomenclature removed link to self for invalid taxon names with no synonymy [#2327]
- Add missing original citation to synonym names in CoLDP export [#2543]
- Uniquify people slow when many roles present [#2528]
- Match combination when protonym has synonym relationships [#2525]
- TaxonNameRelationsip `type_method` returns nil properly on unmatched types [#2504]
- Taxon determinations list in comprehensive task
- The clone button doesn't trigger update taxon name after authors were cloned [#2513]
- Georeference count in new collecting event task [#2519]
- Autofocus in New taxon name task [#2523]
- Geographic area counts as georeference. Soft validations are sometimes loaded before saving georeferences [#2519]
- `import_dataset_id` parameter persist on after resetState in DwC Importer [#2529]
- Updated Ruby gems and Node packages
- In project button [#2530]
- View image matrix is passing wrong ids [#2537]
- Observations with depictions sometimes are removed after move a depiction [#2549]
- Relationship facet in Filter nomenclature
- Determiner facet (param) in Filter collection objects
- Verbatim year input allows alphanumeric numbers in New taxon name
- Labels list renders for those linked to objects, or not

### Changed

- Updated "ICZN binomial" to "ICZN binominal" following the Code dictionary
- Radial annotator Tag form uses a Keyword smart selector [#2564]
- DwcOccurrence is rebuilt/refreshed each time Browse Collection Object is hit
- `footprintWKT` is hidden in Browse CollectionOjbect [#2559]
- Tweak geo coordinate matching on verbatim labels
- Year suffix, stated year, language, translated title and notes added to bibliography rendering via `to_citeproc`
- Removed `label_html` from `/people` responses
- `/people` JSON param from `&include_roles=true` to `&extend[]=roles`
- Prefer project sources in source autocomplete
- Status name 'not for nomenclature' changed to 'not in published work'
- Year letter is no longer appended to year in BibTeX exports
- Include project's name in CoLDP exports filename [#2509]
- Implemented STI for downloads [#2498]\
- Upgraded gnfinder gem that makes use of new REST API
- Refactor help code
- Unified various DwC value returning methods in their own explicitly named extensions
- Isolated CollectionObject filter and API param handling to their own module for reference in multiple controllers
- DwcOccurrence `individualCount` is now Integer
- Database ConnectionTimeoutErrors now result in a 503 response rather than a raise/email-warning
- Added various `:inverse_of` across collection objects related models
- `DwcOccurrence#individualCount` is integer now
- Simplified SQL for ordering GeographicArea shapes
- Tweak validation of ORCIDid format
- Move autocomplete and lookup keyword to CVT controller [#2571]
- Task `Content by nomenclature` can be customized by selecting a Topic
- Remove identifier section in New type specimen
- Nill strings ("\u0000") are stripped from fields before writing

[#2564]: https://github.com/SpeciesFileGroup/taxonworks/issues/2564
[#2512]: https://github.com/SpeciesFileGroup/taxonworks/issues/2512
[#2517]: https://github.com/SpeciesFileGroup/taxonworks/issues/2517
[#915]: https://github.com/SpeciesFileGroup/taxonworks/issues/915
[#1175]: https://github.com/SpeciesFileGroup/taxonworks/issues/1175
[#1230]: https://github.com/SpeciesFileGroup/taxonworks/issues/1230
[#1269]: https://github.com/SpeciesFileGroup/taxonworks/issues/1269
[#1303]: https://github.com/SpeciesFileGroup/taxonworks/issues/1303
[#1467]: https://github.com/SpeciesFileGroup/taxonworks/issues/1467
[#1486]: https://github.com/SpeciesFileGroup/taxonworks/issues/1486
[#1772]: https://github.com/SpeciesFileGroup/taxonworks/issues/1772
[#1775]: https://github.com/SpeciesFileGroup/taxonworks/issues/1775
[#1943]: https://github.com/SpeciesFileGroup/taxonworks/issues/1943
[#2084]: https://github.com/SpeciesFileGroup/taxonworks/issues/2084
[#2186]: https://github.com/SpeciesFileGroup/taxonworks/issues/2186
[#2327]: https://github.com/SpeciesFileGroup/taxonworks/issues/2327
[#2423]: https://github.com/SpeciesFileGroup/taxonworks/issues/2423
[#2498]: https://github.com/SpeciesFileGroup/taxonworks/pull/2498
[#2509]: https://github.com/SpeciesFileGroup/taxonworks/issues/2509
[#2511]: https://github.com/SpeciesFileGroup/taxonworks/issues/2511
[#2519]: https://github.com/SpeciesFileGroup/taxonworks/pull/2519
[#2519]: https://github.com/SpeciesFileGroup/taxonworks/pull/2519
[#2523]: https://github.com/SpeciesFileGroup/taxonworks/pull/2523
[#2526]: https://github.com/SpeciesFileGroup/taxonworks/issues/2526
[#2528]: https://github.com/SpeciesFileGroup/taxonworks/issues/2528
[#2529]: https://github.com/SpeciesFileGroup/taxonworks/pull/2529
[#2530]: https://github.com/SpeciesFileGroup/taxonworks/pull/2530
[#2532]: https://github.com/SpeciesFileGroup/taxonworks/issues/2532
[#2533]: https://github.com/SpeciesFileGroup/taxonworks/issues/2533
[#2542]: https://github.com/SpeciesFileGroup/taxonworks/issues/2542
[#2543]: https://github.com/SpeciesFileGroup/taxonworks/issues/2543
[#2549]: https://github.com/SpeciesFileGroup/taxonworks/pull/2549
[#2558]: https://github.com/SpeciesFileGroup/taxonworks/issues/2558
[#2559]: https://github.com/SpeciesFileGroup/taxonworks/issues/2559
[#2562]: https://github.com/SpeciesFileGroup/taxonworks/issues/2562
[#2563]: https://github.com/SpeciesFileGroup/taxonworks/issues/2563
[#2567]: https://github.com/SpeciesFileGroup/taxonworks/issues/2567
[#2571]: https://github.com/SpeciesFileGroup/taxonworks/issues/1771

## [0.19.7] - 2021-09-09

### Add

- Add link to new type specimen task from type material form
- Export Observation::Media depictions as proxies for Otu depictions in NeXML [#2142]
- Protonym `verbatim_author` parens should be properly closed when present [#2453]
- Protonym `verbatim_author` can not contain digits (like years) [#2452]
- Generic date field component [#2451]
- New taxon determination component
- Smart selectors in asserted distribution and biological association quick forms.

### Changed

- Cleaned up taxon name navigator appearance
- Destroying a loanable object destroys corresponding LoanItems automatically [#2319]
- NeXML image URLs use shortened URLs
- Reorder date fields in comprehensive, extract and new collecting event tasks [#2450]
- Set Vue 3 reactive vuex state in comprehensive store, removed unnecesary mutations and getters
- Updated Ruby gems and Node packages
- Bumped database_cleaner
- Upgraded to ruby 6.1 [#2474]
- Remove Taxon determination slice from OTU quick forms(Radial object)
- Set active author tab in New taxon name [#2461]
- Moved `data-project-id` to project name
- Moved collection object soft validations in comprehensive task [#2491]
- Remove reactivity in map component. Maps should render much faster now

### Fixed

- Tazon name hierarchical navigation broken [#2487]
- CollectionObject filter type material facet bug
- Trim buttons in comprehensive task
- Trip code fields are empty after save.
- Confidence button
- spring not working on MacOS. Now RGeo/Proj is warmed up at initialization time
- Combination preview label in New combination task
- Smart selector is not refreshing after save [#2468]
- Group and formation fields in comprehensive task
- Changed date label [#2473]
- Warning message persists when date exists in User facet [#2480]
- Collection Object TODO List Task does not append right identifier number [#2486]
- Loan item checkboxes reset when loan items "Updated" [#2492]
- Loan item "select/deselect all" buttons missing after vue 3 migration [#2493]
- Checkbox unbinding is not synced with update in Loan task [#2495]
- Filter collection objects shortcuts
- Prevent duplicate shortcuts
- Observation matrix render error
- Fix identifier update in new type specimen task
- Radial menus are inheriting CSS properties in some cases [#2505]
- Taxon determinations list in comprehensive task

[#2487]: https://github.com/SpeciesFileGroup/taxonworks/issues/2487
[#2319]: https://github.com/SpeciesFileGroup/taxonworks/issues/2319
[#2142]: https://github.com/SpeciesFileGroup/taxonworks/issues/2142
[#2453]: https://github.com/SpeciesFileGroup/taxonworks/issues/2453
[#2452]: https://github.com/SpeciesFileGroup/taxonworks/issues/2452
[#2450]: https://github.com/SpeciesFileGroup/taxonworks/pull/2450
[#2451]: https://github.com/SpeciesFileGroup/taxonworks/issues/2451
[#2461]: https://github.com/SpeciesFileGroup/taxonworks/issues/2461
[#2468]: https://github.com/SpeciesFileGroup/taxonworks/issues/2468
[#2473]: https://github.com/SpeciesFileGroup/taxonworks/issues/2473
[#2474]: https://github.com/SpeciesFileGroup/taxonworks/pull/2474
[#2480]: https://github.com/SpeciesFileGroup/taxonworks/issues/2480
[#2486]: https://github.com/SpeciesFileGroup/taxonworks/issues/2486
[#2491]: https://github.com/SpeciesFileGroup/taxonworks/issues/2491
[#2492]: https://github.com/SpeciesFileGroup/taxonworks/issues/2492
[#2493]: https://github.com/SpeciesFileGroup/taxonworks/issues/2493
[#2495]: https://github.com/SpeciesFileGroup/taxonworks/issues/2495
[#2505]: https://github.com/SpeciesFileGroup/taxonworks/issues/2505

## [0.19.6] - 2021-08-20

### Added

- New namespace task [#1891]
- Taxon determination list lock button in comprehensive task [#2088] [#2443]
- Add elevation accuracy parsing for verbatim labels [#2448]

### Changed

- Date fields order in comprehensive task
- Auto advance date fields in comprehensive task
- Changed checkbox label `sortable fields` to `reorder fields` [#2442]
- Modified behaviour of Source autocomplete and pattern for limiting results
- Removed deprecated Travis CI files.

### Fixed

- Source autocomplete exact ID was not prioritized and/or skipped
- Keyboard shortcuts modal reopens when closing help [#2436]
- Title attribute contains html tags on citations in browse OTU
- Increment identifier in CO editor keeps number of leading zeros, changing length of number [#2435]
- Collecting event lock in comprehensive task
- Georeferences are not locked with collecting event [#2449]
- Elevation not being parsed from labels properly [#2447]

[#2088]: https://github.com/SpeciesFileGroup/taxonworks/issues/2088
[#1891]: https://github.com/SpeciesFileGroup/taxonworks/issues/1891
[#2435]: https://github.com/SpeciesFileGroup/taxonworks/issues/2435
[#2436]: https://github.com/SpeciesFileGroup/taxonworks/issues/2436
[#2442]: https://github.com/SpeciesFileGroup/taxonworks/pull/2442
[#2443]: https://github.com/SpeciesFileGroup/taxonworks/issues/2443
[#2447]: https://github.com/SpeciesFileGroup/taxonworks/pull/2447
[#2448]: https://github.com/SpeciesFileGroup/taxonworks/pull/2448
[#2449]: https://github.com/SpeciesFileGroup/taxonworks/issues/2443

## [0.19.5] - 2021-08-18

### Added

- Content smart selector
- Biological association list lock button in comprehensive task
- Dynamic shortcuts for radial annotator and radial object. Shortcut is the first letter of the slice

### Changed

- Replaced panels with modals in Content editor task
- Soft validation panel in new type specimen task
- Replaced create predicate with link to project attributes customization page in custom attributes section [#2426]
- Editing from Browse Collecting Event now redirects to Collecting Event task.

### Fixed

- Create georeference from verbatim does not take uncertainty into account [#2421]
- Cannot edit Georeference uncertainty in New collecting event task [#2420]
- Georeference edit/delete button does not show up immediately on creation [#2422]
- Unable to create a type specimen with an existing collection object
- Catalog number is not updating after selecting another type specimen
- Duplicate verbatim georeference on generate label in New collecting event and comprehensive tasks [#2427]
- Biological association list persist after save and create a new collection object in comprehensive task
- Comprehensive specimen task reset button adds false history entry in browser [#2432]
- Whitespace chars in label preventing georefs to be properly parsed [#2415]
- Rubocop broken settings
- Extra semicolon in collecting event label when verbatim locality is blank

[#2415]: https://github.com/SpeciesFileGroup/taxonworks/issues/2415
[#2420]: https://github.com/SpeciesFileGroup/taxonworks/issues/2420
[#2421]: https://github.com/SpeciesFileGroup/taxonworks/issues/2421
[#2422]: https://github.com/SpeciesFileGroup/taxonworks/issues/2422
[#2426]: https://github.com/SpeciesFileGroup/taxonworks/issues/2426
[#2432]: https://github.com/SpeciesFileGroup/taxonworks/issues/2432

## [0.19.4] - 2021-08-13

### Fixed

- Geographic areas not scoped in Georeferences pane until georeference added [#2408]
- Georeference from previous collecting event shows up on new collecting event [#2411]
- Fix biological associations in comprehensive form
- Removed events for links in radial navigation [#2412]

### Added

- Storage for PDF viewer

[#2408]: https://github.com/SpeciesFileGroup/taxonworks/issues/2408
[#2411]: https://github.com/SpeciesFileGroup/taxonworks/issues/2411
[#2412]: https://github.com/SpeciesFileGroup/taxonworks/issues/2412

## [0.19.3] - 2021-08-10

### Added

- Added soft-validation for loan if no docummentation
- Added validation on 5 date fields in the loan, setting the priority of events.
- Added search on alternative title in the Sorce autocomplete
- Pdf icon in citation by source
- Cancel function for http requests
- Edit mode for contents in Quick forms [#2385]
- Soft validation for collection object, type material, biological association, georeferences and taxon determinations in comprehensive task [#2396]
- Pinned icon for images in radial annotator [#1919]

### Fixed

- Biological association link_tag entities not metamorphosized [#2392]
- Updated sorting for sources in autocomplete. Sources used in the same project are prioritized
- Updated sorting for people in autocomplete. People used in the same project are prioritized
- Autocomplete in Interactive key task
- Copy and clone option in Matrix Row Coder
- Edit biological associations form, broken HTML and fields incorrectly mapped [#2370]
- Hidden pin and lock icons in asserted distribution quick form
- biological_association_link helper
- Confidence button
- Dynamic rows/columns are not destroyable [#2375]
- Asserted distribution edit view [#2371]
- Missing citation and soft validation icons in New asserted distribution task
- Typo preventing labels listings from working
- Refresh summary in data view after use radial annotator
- Collecting event soft validation in comprehensive task [#2091]
- Missing param for BibTex [#2397]
- Citation source not added to project if already in another project
- Incorrect TypeMaterial type type validation for ICN [#2378]

### Changed

- Biological association links now link to subject, association (click middle) and object
- Sort property, `name` to `cached` in Filter nomenclature [#2372]
- Replaced property `verbatim_author` to `cached_author_year` for csv download [#2373]
- Refactor notification code, replaced jQuery for js vanilla
- Keyboard shortcuts code, replaced jQuery with vanilla JS
- Pinboard code, replaced jQuery with vanilla JS
- Annotations code, replaced jQuery with vanilla JS
- Dropzone timeout [#2384]
- Edit link redirect to new collecting event task [#2387]
- Edit link redirect to comprehensive specimen digitization [#2394]
- Add source to project when tagged [#1436]
- Updated Ruby gems and Node packages
- Updated ruby gems

[#1436]: https://github.com/SpeciesFileGroup/taxonworks/issues/1436
[#2392]: https://github.com/SpeciesFileGroup/taxonworks/issues/2392
[#1919]: https://github.com/SpeciesFileGroup/taxonworks/issues/1919
[#2091]: https://github.com/SpeciesFileGroup/taxonworks/issues/2091
[#2370]: https://github.com/SpeciesFileGroup/taxonworks/issues/2370
[#2371]: https://github.com/SpeciesFileGroup/taxonworks/issues/2371
[#2372]: https://github.com/SpeciesFileGroup/taxonworks/issues/2372
[#2373]: https://github.com/SpeciesFileGroup/taxonworks/issues/2373
[#2375]: https://github.com/SpeciesFileGroup/taxonworks/issues/2375
[#2378]: https://github.com/SpeciesFileGroup/taxonworks/pull/2378
[#2384]: https://github.com/SpeciesFileGroup/taxonworks/issues/2384
[#2385]: https://github.com/SpeciesFileGroup/taxonworks/issues/2385
[#2387]: https://github.com/SpeciesFileGroup/taxonworks/issues/2387
[#2391]: https://github.com/SpeciesFileGroup/taxonworks/issues/2391
[#2394]: https://github.com/SpeciesFileGroup/taxonworks/issues/2394
[#2397]: https://github.com/SpeciesFileGroup/taxonworks/issues/2397

## [0.19.2] - 2021-07-27

### Added

- OriginRelationship display in Browse collection object [#2362]
- Accession/Deaccession section in Collection object match task [#2353]
- Similar objects section in MRC
- Soft validation in Edit/new matrix task
- Update download form [#2335]
- Check and question icons

### Changed

- Upgraded from Ruby version 2.7.3 to 2.7.4
- Updated ruby gems
- Object validation component

### Fixed

- Autocomplete in Interactive key task
- Copy and clone option in Matrix Row Coder
- Edit biological associations form [#2370]

[#2370]: https://github.com/SpeciesFileGroup/taxonworks/issues/2370

## [0.19.2] - 2021-07-27

### Added

- OriginRelationship display in Browse collection object [#2362]
- Accession/Deaccession section in Collection object match task [#2353]
- Similar objects section in MRC
- Soft validation in Edit/new matrix task
- Update download form [#2335]
- Check and question icons

### Changed

- Upgraded from Ruby version 2.7.3 to 2.7.4
- Updated ruby gems
- Object validation component

### Fixed

- Help plugin
- Original relationships in Collection object quick form
- CO Quick forms in comprehensive specimen digitization [#2354]
- Biological associations in OTU quick forms
- Update type species in new taxon name task

[#2362]: https://github.com/SpeciesFileGroup/taxonworks/issues/2362
[#2353]: https://github.com/SpeciesFileGroup/taxonworks/issues/2353
[#2354]: https://github.com/SpeciesFileGroup/taxonworks/issues/2354

## [0.19.1] - 2021-07-15

### Added

- Autogenerated description for OTU based on observation_matrix
- Description section in Browse OTU
- `observation_matrix_id` param in Browse OTU task
- Description in Matrix row coder

### Changed

- Update `per` value from 5 to 500 in citations controller [#2336]
- Updated ruby gems
- Upgraded biodiversity gem to 5.3.1 (uses named params)

### Fixed

- Show selected options for biological associations in comprehensive specimen digitization task [#2332]
- Option to hide "Attributes", "Buffered", "Citations" and "Depictions" sections in comprehensive specimen digitization task [#2333]
- Missing fields in comprehensive form
- Fields not showing in "original combination and rank" section in New taxon name [#2346]

[#2332]: https://github.com/SpeciesFileGroup/taxonworks/issues/2332
[#2333]: https://github.com/SpeciesFileGroup/taxonworks/issues/2333
[#2336]: https://github.com/SpeciesFileGroup/taxonworks/issues/2336
[#2346]: https://github.com/SpeciesFileGroup/taxonworks/issues/2346

## [0.19.0] - 2021-07-08

### Added

- Added new ICZN status: Invalid family group name due to synonymy of type genus replaced before 1961
- Edit image matrix and view image matrix in observation matrices dashboard
- WTK component in comprehensive digitization form [#2245]
- Add invalid relationship checkbox on clone button in New taxon name task [#2171]
- Download PDF button for documents in New source task [#2102]
- Padial annotator for sources in New asserted distribution task [#2105]
- Radial annotator for references in Browse Nomenclature/OTU tasks [#2103]
- Depict person in New image task [#2321]
- Move to `person` option for Depictions slice in Radial annotator
- Sort by nomenclature in edit/new observation matrix task [#1748]
- Added authors facet in Filter nomenclature task
- Citations panel for Collection object section with lock option in comprehensive specimen digitization task [#2328]

### Changed

- Updated ruby gems
- Migrate Vue 2.6 to Vue 3.1.4
- `geographic_area_ids` to `geographic_area_id` in collection objects controller
- Manage synonyms display only one level children in New taxon name [#2213]
- Filter status and relationships according nomenclatural code in Filter nomenclature task [#2157]
- User facet data range now allows to search for both criteria (`updated_at`, `created_at`) [#2317]

### Fixed

- Updated author string for botanical names
- Timeline rendering error in Browse OTU
- Fix wildcard by attribute in Filter collection object
- Confidences modal height in radial annotator [#2304]
- Fix empty search in Filter collection objects
- Clean documents list on reset in New source
- Missing hexagon soft validation in comprehensive specimen digitization task
- Match by collection object is and tag creation in Collection object match
- Destroy container when all other objects in container are deleted [#2322]
- Clicking on "Tag" in Filter collection objects does not add tag [#2323]

[#1748]: https://github.com/SpeciesFileGroup/taxonworks/issues/1748
[#2102]: https://github.com/SpeciesFileGroup/taxonworks/issues/2102
[#2103]: https://github.com/SpeciesFileGroup/taxonworks/issues/2103
[#2105]: https://github.com/SpeciesFileGroup/taxonworks/issues/2105
[#2157]: https://github.com/SpeciesFileGroup/taxonworks/issues/2157
[#2171]: https://github.com/SpeciesFileGroup/taxonworks/issues/2171
[#2213]: https://github.com/SpeciesFileGroup/taxonworks/issues/2213
[#2245]: https://github.com/SpeciesFileGroup/taxonworks/issues/2245
[#2304]: https://github.com/SpeciesFileGroup/taxonworks/issues/2304
[#2317]: https://github.com/SpeciesFileGroup/taxonworks/issues/2317
[#2321]: https://github.com/SpeciesFileGroup/taxonworks/issues/2321
[#2322]: https://github.com/SpeciesFileGroup/taxonworks/issues/2322
[#2323]: https://github.com/SpeciesFileGroup/taxonworks/issues/2323

## [0.18.1] - 2021-06-09

### Added

- Params for `/api/v1/images/` [#1906]
- Params referenced in `/collection_objects` to `/collecting_events`
- `/api/v1/taxon_name_classifications/` endpoint [#2276]
- `/api/v1/taxon_name_relationships/` endpoint [#2277]
- TaxonName cached_is_valid boolean, takes into account Relationships and Classifications
- Status to TaxonName autocomplete [#2086]
- otu_filter param to interactive keys task
- Radial annotator in New extract [#2272]

### Fixed

- Fix for author string for unjustified emendation
- Scope has_many related data to project properly [#2265]
- Refresh event for smart selectors [#2255]
- Edit type material in comprehensive form [#2253]
- Reset selected ids on new search in observation matrices dashboard
- Tiff images are not render on image viewer
- Removed reachable `byebug` call
- Protocol not displayed after select it [#2279]
- image aspect ratio in Transcribe depiction trask [#2273]

### Changed

- Unify Task Collecting Event filter look/feel [#2203]
- Params to `/taxon_name_relationships`, see [#2277]
- CoL Data Package scoping updates
- Removed incompatible identifier object type check for Identifier filter concerns
- Unified some CollectingEvent filter param to singular pattern (collector_ids, otu_ids, geographic_area_ids)
- Plural params for identifiers API endpoint merged to array single form. e.g., identifier_object_ids[]=47&identifier_object_ids[]=2232 => identifier_object_id[]=47&identifier_object_id[]=2232. [#2195]
- Updated Ruby gems and node packages
- `that_is_valid` scope now references `cached_is_valid` [#2242]
- `that_is_invalid` scope now references `cached_is_valid` [#2242]
- `calculated_valid` replaces `that_is_valid` [#2242]
- `calculated_invalid` replaces `that_is_invalid` [#2242]
- remove unused TaxonName#cached_higher_classification

[#2265]: https://github.com/SpeciesFileGroup/taxonworks/issues/2265
[#1906]: https://github.com/SpeciesFileGroup/taxonworks/issues/1906
[#2203]: https://github.com/SpeciesFileGroup/taxonworks/issues/2203
[#2276]: https://github.com/SpeciesFileGroup/taxonworks/issues/2276
[#2277]: https://github.com/SpeciesFileGroup/taxonworks/issues/2277
[#2195]: https://github.com/SpeciesFileGroup/taxonworks/pull/2195
[#2242]: https://github.com/SpeciesFileGroup/taxonworks/issues/2242
[#2086]: https://github.com/SpeciesFileGroup/taxonworks/pull/2086
[#2253]: https://github.com/SpeciesFileGroup/taxonworks/issues/2253
[#2255]: https://github.com/SpeciesFileGroup/taxonworks/issues/2255
[#2272]: https://github.com/SpeciesFileGroup/taxonworks/issues/2272
[#2273]: https://github.com/SpeciesFileGroup/taxonworks/issues/2273
[#2279]: https://github.com/SpeciesFileGroup/taxonworks/issues/2279

## [0.18.0] - 2021-05-14

### Added

- Added `destroyed_redirect` to object radial JSON
- "Not specified" facet to Filter nomenclature [#2226]
- New extract task interface [#1934]
- citation experiment `/api/v1/cite/count_valid_species?taxon_name=Pteromalus` [#2230]
- jsconfig.json for Visual Studio Code
- Image matrix viewer in Image matrix
- Image matrix button in observation dashboard task
- Image matrix link in Interactive keys task
- Export scss vars to javascript
- Pagination count in Filter nomenclature
- OTU depictions column on view mode in Image matrix task
- Grid table component
- SVG Icon component
- OTU depictions draggable in image matrix
- Observations depictions in Browse OTU
- `Ctrl/Alt + V` shortcut for New Collecting event in Comprehensive task [#2248]
- Zoom button in comprehensive form

### Changed

- CollectingEvent autocomplete/object_Tag only shows verbatim lat/long
- Removed `allow_destroy` from object radial JSON
- Made returning count from /controlled_vocabulary_terms optional # @jlpereira Potentially UI breaking check for use, and add &count=true to request if required
- Removed quantification fields from Extract
- Warning message on nuke action in Grid digitize task [#2229]
- Upgraded from Ruby version 2.7.2 to 2.7.3
- Upgraded to Node 14 LTS
- Updated Ruby gems and Node packages
- node-sass to dart-sass
- Refactor image matrix edit table
- Webpack configuration to export sass vars
- Images size in image section on Browse otu

### Fixed

- JSON for geographic area parents (no parent raise)
- Hide soft validation section if is empty in New collecting events task
- 404 error when deleting records from data interfaces [#2223]
- Rank order on New combination preview
- Redirect after destroy a combination [#2169]
- Drag and drop depictions in Image Matrix
- Georeference error message in comprehensive task [#2222]
- Number of uses not displayed in Uniquify people task [#2219]
- SVG Image box in comprehensive [#2262]

[#1934]: https://github.com/SpeciesFileGroup/taxonworks/issues/1934
[#2169]: https://github.com/SpeciesFileGroup/taxonworks/issues/2169
[#2219]: https://github.com/SpeciesFileGroup/taxonworks/issues/2219
[#2222]: https://github.com/SpeciesFileGroup/taxonworks/issues/2222
[#2223]: https://github.com/SpeciesFileGroup/taxonworks/pull/2223
[#2226]: https://github.com/SpeciesFileGroup/taxonworks/pull/2226
[#2229]: https://github.com/SpeciesFileGroup/taxonworks/issues/2229
[#2230]: https://github.com/SpeciesFileGroup/taxonworks/issues/2230
[#2248]: https://github.com/SpeciesFileGroup/taxonworks/issues/2248

## [0.17.1] - 2021-04-30

### Added

- Moved endpoints to own model file
- Permit params on client side
- OTU picker on new observation matrix [#2209]

### Fixed

- Frame overlaps in interactive key task [#2202]
- Parse coordinate characters on comprehensive and new collecting event tasks
- Hide row/column panel on new observation matrix
- Soft validation section is always visible [#2211]
- Ambiguous column problem in query for previous/next collecting event navigation.
- Merge people count [#2218]

### Changed

- Replaced 1KB minimum image file size restriction with dimensions check (16 pixels minimum each) [#2201]
- Switch selector on new observation matrix
- Increment pdf filesize to 512MB [#2212]
- Updated gems and npm packages

[#2201]: https://github.com/SpeciesFileGroup/taxonworks/issues/2201
[#2202]: https://github.com/SpeciesFileGroup/taxonworks/issues/2202
[#2209]: https://github.com/SpeciesFileGroup/taxonworks/issues/2209
[#2211]: https://github.com/SpeciesFileGroup/taxonworks/issues/2211
[#2212]: https://github.com/SpeciesFileGroup/taxonworks/issues/2212
[#2218]: https://github.com/SpeciesFileGroup/taxonworks/issues/2218

## [0.17.0] - 2021-04-23

### Added

- Adds SoftValidation component with fix buttons, and wrench (goto fix) links [#207]
- Database index on `Identifiers#cached`
- Tests for base #next/#previous [#2163]
- `create_backup_directory` flag to create backup directory if it does not exist for taxonworks rake tasks requiring `backup_directory`.
- Edit inline options on edit/new loan task [#2184]
- Shortcut legend on new taxon name task
- Help tip and placeholder for definition in Manage controlled vocabulary task [#2196]

### Fixed

- Bad `project_token` to API should not raise
- Descriptor::Qualitative destruction destroys rather than raises when character states unused.
- Previous navigation [#2163]
- Documenting source doesn't add source to project [#2172]
- Added missing params biocuration_class_ids and biological_relationship_ids to collection_objects_controller filter params. [skip-ci]
- incorrect author string for misspelled combination is fixed
- Missing data migration for `ObservationMatrixColumnItem::SingleDescriptor` to `ObservationMatrixColumnItem::Single:Descriptor`
- Show observation matrices count on radial object [#2158]
- Overflow on New observation matrix [#2168]
- Clear geographic area after reset [#2174]
- PK sequence not set up properly on project export
- Local identifiers' cached values not being updated when updating namespace [#2175]
- Uncertainty sign not populating in label [#2109]
- Pressing the reset button doesn't reset the by attribute facet in Filter collection object [#2180]
- Fix routes in edit/new observation matrices task [#2198]

### Changed

- Refactor SoftValidations and params including specs [#1972][#768]
- Removed legacy non TaxonWorks agnostic import rake tasks (moving to their own repos)
- Updated script predicting masculine, feminine and neuter species name forms
- Changed how `GeographicArea#find_by_lat_long` is built (UNION, not OR)
- Changed TaxonName string for superspecies names
- Updated y18n node package to version 4.0.1 [#2160]
- Replaced Canvas for SVG radial menu
- Close radial object after select a matrix on observation matrices slice [#2165]
- Radial menu slices position

[#768]: https://github.com/SpeciesFileGroup/taxonworks/issues/768
[#207]: https://github.com/SpeciesFileGroup/taxonworks/issues/207
[#1972]: https://github.com/SpeciesFileGroup/taxonworks/issues/1972
[#2109]: https://github.com/SpeciesFileGroup/taxonworks/issues/2109
[#2163]: https://github.com/SpeciesFileGroup/taxonworks/issues/2163
[#2160]: https://github.com/SpeciesFileGroup/taxonworks/issues/2160
[#2168]: https://github.com/SpeciesFileGroup/taxonworks/issues/2168
[#2172]: https://github.com/SpeciesFileGroup/taxonworks/issues/2172
[#2175]: https://github.com/SpeciesFileGroup/taxonworks/issues/2175
[#2174]: https://github.com/SpeciesFileGroup/taxonworks/issues/2174
[#2184]: https://github.com/SpeciesFileGroup/taxonworks/issues/2184
[#2196]: https://github.com/SpeciesFileGroup/taxonworks/issues/2196
[#2198]: https://github.com/SpeciesFileGroup/taxonworks/issues/2198

## [0.16.6] - 2021-03-26

### Added

- Community stats for `/api/v1/stats` [#2061]
- Add by-project param for `/api/v1/stats` [#2056]

### Fixed

- `browse_otu_link` handles nil [#2155]

[#2056]: https://github.com/SpeciesFileGroup/taxonworks/issues/2056
[#2061]: https://github.com/SpeciesFileGroup/taxonworks/issues/2061
[#2155]: https://github.com/SpeciesFileGroup/taxonworks/issues/2155
[#2158]: https://github.com/SpeciesFileGroup/taxonworks/issues/2158
[#2165]: https://github.com/SpeciesFileGroup/taxonworks/issues/2165

## [0.16.5] - 2021-03-25

### Added

- softvalidation fix for transfer of type species into coordinate subgenus
- Link from Browse colleciton object to Browse OTU for current OTU det [#2154]
- Collection object filter params for preparation and buffered fields [#2118]
- Added soft_validations and fixes for coordinate name citations and roles.
- `/collection_objects/123/navigation.json` route/view
- Determination, OTU and repository smart selectors on New image task [#2101]
- Georeferences coordinates in label generate on New collecting event [#2107]
- Lock buttons on New image [#2101]
- Open PDF slider in all tabs [#2106]
- TaxonName autocomplete by internal id
- bind `alt/ctrl + f` to focus the search autocomplete [#2132]
- Annotations on Browse nomenclature
- Collectors facet on Filter collection objects task
- Preview use panel on Manage controlled vocabulary [#2135]

### Changed

- Renamed -`otus_redirect` to `browse_otu_link`
- Updated Protonym.list_of_coordinate_names query. It helps for soft validation.
- Nexus output file was modified to present full name of the of the taxon. TNT export was not changed.
- Lock background color [#2112]
- sortArray function now return a natural sort
- Open confirmation modal and focus new button on New taxon name
- Next and previous links for id and identifier on comprehensive task [#2134]
- Determiner facet on Filter collection objects task
- Updated gems (`bundle update` without altering `Gemfile`)

### Fixed

- updated softvalidation for non binominal names
- updated label for species-group rank TaxonName
- Compute print column divisions with barcode style labels [#1993]
- Object tag for TaxonNameRelationship inverted [#2100]
- Collection object filter, collecting event related params were not being passed [#1807]
- Collection object filter with/out facets, in part [#1455]
- CoLDP missing values for names without original combinations [#2146]
- Multiple parent OTUs via parent_otu_id raised in CoLDp export [#2011]
- Not being able to get pinboard items on some circumstances
- `Request-URI Too Large` loading georeferences on Browse OTU
- Tab order near parent when name is pinned [#2130]
- Spinner in distribution section on Browse OTU
- Destroying a container goes to 404 page [#2133]
- Missing Determiner param [#2119]
- Refresh status and relationship list on rank change [#2010]
- Remove map shapes after reset form on Filter collection objects
- Disabled `Create georeference from verbatim` button when latitude and longitude are not available [#2152]
- Fix create determinations and biocurations before turn off the spinner [#1991]

[#1993]: https://github.com/SpeciesFileGroup/taxonworks/issues/1993
[#1991]: https://github.com/SpeciesFileGroup/taxonworks/issues/1991
[#2100]: https://github.com/SpeciesFileGroup/taxonworks/issues/2100
[#2154]: https://github.com/SpeciesFileGroup/taxonworks/issues/2154
[#1455]: https://github.com/SpeciesFileGroup/taxonworks/issues/1455
[#1807]: https://github.com/SpeciesFileGroup/taxonworks/issues/1807
[#2114]: https://github.com/SpeciesFileGroup/taxonworks/issues/2114
[#2146]: https://github.com/SpeciesFileGroup/taxonworks/issues/2146
[#2010]: https://github.com/SpeciesFileGroup/taxonworks/issues/2010
[#2011]: https://github.com/SpeciesFileGroup/taxonworks/issues/2011
[#2101]: https://github.com/SpeciesFileGroup/taxonworks/issues/2101
[#2106]: https://github.com/SpeciesFileGroup/taxonworks/issues/2101
[#2107]: https://github.com/SpeciesFileGroup/taxonworks/issues/2107
[#2112]: https://github.com/SpeciesFileGroup/taxonworks/issues/2112
[#2118]: https://github.com/SpeciesFileGroup/taxonworks/issues/2118
[#2119]: https://github.com/SpeciesFileGroup/taxonworks/issues/2119
[#2130]: https://github.com/SpeciesFileGroup/taxonworks/issues/2130
[#2131]: https://github.com/SpeciesFileGroup/taxonworks/issues/2131
[#2132]: https://github.com/SpeciesFileGroup/taxonworks/issues/2132
[#2133]: https://github.com/SpeciesFileGroup/taxonworks/issues/2133
[#2152]: https://github.com/SpeciesFileGroup/taxonworks/issues/2133
[#2135]: https://github.com/SpeciesFileGroup/taxonworks/issues/2135

## [0.16.4] - 2021-03-09

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

- Soft validation scope for AssertedDistributions not scoped to taxon [#1971]
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

[#1971]: https://github.com/SpeciesFileGroup/taxonworks/issues/1971
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

- CVT smart selectors/pinboard scope broken [#1940][#1941]
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
- Spec to test md5 of multi-line verbatim labels (refs [#1572])
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
[unreleased]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.52.2...development
[0.52.2]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.52.1...v0.52.2
[0.52.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.52.0...v0.52.1
[0.52.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.51.0...v0.52.0
[0.51.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.50.1...v0.51.0
[0.50.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.50.0...v0.50.1
[0.50.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.49.1...v0.50.0
[0.49.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.49.0...v0.49.1
[0.49.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.48.0...v0.49.0
[0.48.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.47.0...v0.48.0
[0.47.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.46.1...v0.47.0
[0.46.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.46.0...v0.46.1
[0.46.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.45.0...v0.46.0
[0.45.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.44.3...v0.45.0
[0.44.3]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.44.2...v0.44.3
[0.44.2]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.44.1...v0.44.2
[0.44.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.44.0...v0.44.1
[0.44.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.43.3...v0.44.0
[0.43.3]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.43.2...v0.43.3
[0.43.2]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.43.1...v0.43.2
[0.43.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.43.0...v0.43.1
[0.43.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.42.0...v0.43.0
[0.42.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.41.1...v0.42.0
[0.41.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.41.0...v0.41.1
[0.41.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.40.6...v0.41.0
[0.40.6]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.40.5...v0.40.6
[0.40.5]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.40.4...v0.40.5
[0.40.4]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.40.3...v0.40.4
[0.40.3]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.40.2...v0.40.3
[0.40.2]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.40.1...v0.40.2
[0.40.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.40.0...v0.40.1
[0.40.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.39.0...v0.40.0
[0.39.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.38.3...v0.39.0
[0.38.3]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.38.2...v0.38.3
[0.38.2]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.38.1...v0.38.2
[0.38.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.38.0...v0.38.1
[0.38.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.37.1...v0.38.0
[0.37.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.37.0...v0.37.1
[0.37.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.36.0...v0.37.0
[0.36.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.35.3...v0.36.0
[0.35.3]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.35.2...v0.35.3
[0.35.2]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.35.1...v0.35.2
[0.35.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.35.0...v0.35.1
[0.35.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.34.6...v0.35.0
[0.34.6]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.34.5...v0.34.6
[0.34.5]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.34.4...v0.34.5
[0.34.4]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.34.3...v0.34.4
[0.34.3]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.34.2...v0.34.3
[0.34.2]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.34.1...v0.34.2
[0.34.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.34.0...v0.34.1
[0.34.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.31.1...v0.34.0
[0.33.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.33.0...v0.33.1
[0.33.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.32.3...v0.33.0
[0.32.3]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.32.2...v0.32.3
[0.32.2]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.32.1...v0.32.2
[0.32.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.32.0...v0.32.1
[0.32.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.31.3...v0.32.0
[0.31.3]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.31.2...v0.31.3
[0.31.2]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.31.1...v0.31.2
[0.31.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.31.0...v0.31.1
[0.31.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.30.3...v0.31.0
[0.30.3]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.30.2...v0.30.3
[0.30.2]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.30.1...v0.30.2
[0.30.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.30.0...v0.30.1
[0.30.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.29.6...v0.30.0
[0.29.6]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.29.5...v0.29.6
[0.29.5]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.29.4...v0.29.5
[0.29.4]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.29.3...v0.29.4
[0.29.3]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.29.2...v0.29.3
[0.29.2]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.29.1...v0.29.2
[0.29.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.29.0...v0.29.1
[0.29.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.28.1...v0.29.0
[0.28.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.28.0...v0.28.1
[0.28.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.27.3...v0.28.0
[0.27.3]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.27.2...v0.27.3
[0.27.2]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.27.1...v0.27.2
[0.27.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.27.0...v0.27.1
[0.27.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.26.2...v0.27.0
[0.26.2]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.26.1...v0.26.2
[0.26.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.26.0...v0.26.1
[0.26.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.25.0...v0.26.0
[0.25.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.24.5...v0.25.0
[0.24.5]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.24.4...v0.24.5
[0.24.4]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.24.3...v0.24.4
[0.24.3]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.24.2...v0.24.3
[0.24.2]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.24.1...v0.24.2
[0.24.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.24.0...v0.24.1
[0.24.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.23.1...v0.24.0
[0.23.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.23.0...v0.23.1
[0.23.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.22.7...v0.23.0
[0.22.7]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.22.6...v0.22.7
[0.22.6]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.22.5...v0.22.6
[0.22.5]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.22.4...v0.22.5
[0.22.4]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.22.3...v0.22.4
[0.22.3]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.22.2...v0.22.3
[0.22.2]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.22.1...v0.22.2
[0.22.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.22.0...v0.22.1
[0.22.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.21.3...v0.22.0
[0.21.3]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.21.2...v0.21.3
[0.21.2]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.21.1...v0.21.2
[0.21.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.21.0...v0.21.1
[0.21.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.20.1...v0.21.0
[0.20.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.20.0...v0.20.1
[0.20.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.19.7...v0.20.0
[0.19.7]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.19.6...v0.19.7
[0.19.6]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.19.5...v0.19.6
[0.19.5]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.19.4...v0.19.5
[0.19.4]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.19.3...v0.19.4
[0.19.3]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.19.2...v0.19.3
[0.19.2]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.19.1...v0.19.2
[0.19.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.19.0...v0.19.1
[0.19.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.18.1...v0.19.0
[0.18.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.18.0...v0.18.1
[0.18.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.17.1...v0.18.0
[0.17.1]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.17.0...v0.17.1
[0.17.0]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.16.6...v0.17.0
[0.16.6]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.16.5...v0.16.6
[0.16.5]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.16.4...v0.16.5
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

---

The following versions predate this CHANGELOG. You may check the comparison reports generated by GitHub by clicking the versions below

| <!-- -->   | <!-- -->                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 0.12.x     | [0.12.3](2020-06-04) [0.12.2](2020-06-02) [0.12.1](2020-05-29) [0.12.0](2020-05-15)                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| 0.11.x     | [0.11.0](2020-04-17)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| 0.10.x     | [0.10.9](2020-04-03) [0.10.8](2020-03-27) [0.10.7](2020-03-26) [0.10.6](2020-03-18) [0.10.5](2020-03-11) [0.10.4](2020-03-04) [0.10.3](2020-02-25) [0.10.2](2020-02-22) [0.10.1](2020-02-21) [0.10.0](2020-02-20)                                                                                                                                                                                                                                                                                                                   |
| 0.9.x      | [0.9.8](2020-02-05) [0.9.7](2020-02-03) [0.9.6](2020-01-29) [0.9.5](2020-01-14) [0.9.4](2020-01-10) [0.9.3](2019-12-23) [0.9.2](2019-12-18) [0.9.1](2019-12-16) [0.9.0](2019-12-13)                                                                                                                                                                                                                                                                                                                                                 |
| 0.8.x      | [0.8.9](2019-12-11) [0.8.8](2019-12-09) [0.8.7](2019-12-06) [0.8.6](2019-12-06) [0.8.5](2019-11-27) [0.8.4](2019-11-26) [0.8.3](2019-11-22) [0.8.2](2019-11-21) [0.8.1](2019-11-19) [0.8.0](2019-11-16)                                                                                                                                                                                                                                                                                                                             |
| 0.7.x      | [0.7.4](2019-10-23) [0.7.3](2019-10-19) [0.7.2](2019-10-05) [0.7.1](2019-10-02) [0.7.0](2019-09-30)                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| 0.6.x      | [0.6.1](2019-06-16) [0.6.0](2019-06-14)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| 0.5.x      | [0.5.4](2019-05-02) [0.5.3](2019-05-02) [0.5.2](2019-04-23) [0.5.1](2019-04-18) [0.5.0](2019-04-10)                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| 0.4.x      | [0.4.5](2018-12-14) [0.4.4](2018-12-06) [0.4.3](2018-12-04) [0.4.2](2018-12-04) [0.4.1](2018-11-28) [0.4.0](2018-11-08)                                                                                                                                                                                                                                                                                                                                                                                                             |
| 0.3.x (\*) | [0.3.16](2018-09-24) [0.3.15](2018-09-17) [0.3.14](2018-09-11) [0.3.13](2018-09-11) [0.3.12](2018-05-14) [0.3.11](2018-05-11) [0.3.9](2018-05-11) [0.3.7](2018-05-10) [0.3.6](2018-05-10) [0.3.4](2018-05-02) [0.3.3](2018-05-02) [0.3.2](2018-03-27) [0.3.1](2018-03-08) [0.3.0](2018-03-08)                                                                                                                                                                                                                                       |
| 0.2.x (\*) | [0.2.29](2018-02-05) [0.2.28](2017-07-19) [0.2.27](2017-07-19) [0.2.26](2017-07-16) [0.2.25](2017-07-12) [0.2.24](2017-07-12) [0.2.23](2017-07-11) [0.2.22](2017-07-11) [0.2.21](2017-07-10) [0.2.20](2017-07-10) [0.2.19](2017-07-10) [0.2.18](2017-07-10) [0.2.17](2017-07-10) [0.2.15](2017-07-10) [0.2.11](2017-07-10) [0.2.10](2017-07-10) [0.2.9](2017-07-10) [0.2.8](2017-07-10) [0.2.6](2017-07-10) [0.2.5](2017-07-10) [0.2.4](2017-07-10) [0.2.3](2017-07-10) [0.2.2](2017-07-10) [0.2.1](2017-07-10) [0.2.0](2017-07-10) |
| 0.1.x      | _Unreleased_                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| 0.0.x      | [0.0.10](2017-06-23) [0.0.9](2017-06-23) [0.0.8](2017-06-09) [0.0.6](2017-06-09) [0.0.5](2017-06-09) [0.0.4](2017-06-09) [0.0.3](2017-06-02) [0.0.2](2017-06-01) 0.0.1(\*\*) (2017-06-01)                                                                                                                                                                                                                                                                                                                                           |

_(\*) Missing versions have not been released._

_(\*\*) Report cannot be provided as this is the first release._

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
