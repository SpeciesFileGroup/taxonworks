# Changelog
All (hopefully) notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
This project <em>does not yet</em> adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) as the API is evolving and MINOR patches may be backwards incompatible.

## [unreleased]

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
- DwCA export is *much* faster
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
- API routes for observation matrices  via `/api/v1/observation_matrices`
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
- No longer exposing exception data for *failed* records (not to be confused with *errored*) in DwC importer.
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
- Failure when setting up namespaces in DwC importer with datasets having *unnamed* columns
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
- Removed footprintWKT from DwcOccurrence.  It will be re-instated as optional in the future.
- Removed GeographicArea from consideration as a _georeference_ in DwcOccurrence
- Changed `associatedMedia` format, pointed it to
- Removed redundant 'Rebuild' button from Browse collection objects

### Fixed
- DwC Dashboard past links are properly scoped
- DwC Dashboard graphs show proper count ranges
- DwC archive no longer truncated at 10k records
- OccurrenceID was not being added to DwcOccurrence attributes in all cases [#2573]
- Observation matrix show expand was referencing the wrong id  [#2540]
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

[unreleased]: https://github.com/SpeciesFileGroup/taxonworks/compare/v0.24.3...development
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
