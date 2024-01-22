# Architecture

Additional details may be found in the README.md at the base of each folder.

TODO: There are various misc libaries that should be moved out of the base of this folder.

## analysis
Code that is primarily computation, as opposed to say state management.

## assets
TODO: @locodelassembly @jlperiera why is this a .keep 

## batch_file_load
Libraries that handle the import of more than one file at a time (e.g. a zip of many FASTA files).

## batch_load
Libraries that handle the import of a single file with many records.

## catalog
Libraries that use `lib/catalog.rb`, `catalog/entry_item.rb` and `catalog/entry.rb` pattern to summarize and report data, often in "catalog" style.  

## export
Libraries that export to specific standards or formats that are not, or primarily not, defined in TaxonWorks. E.g. DwC, CoLDP, DOT.

## forms
To be deprecated likely.  Tools that faciliate Rails native form field locking between new records.

## generators
Rails generators. Templates for scaffolding new Rails code.

## gis
TODO: Likely move to Tools if specific to TaxonWorks data aggregations
At present geo_json methods. 

## housekeeping
Libraries that use or facilitate the use of `project_id`, `created_by_id`, `updated_by_id`, `created_at`, `updated_at`.  This is perhaps a good candidate for extraction to a Gem.

## hub
Libraries to facilate linking metadata used in the /hub UI/UX.

## nexml
Not used. A prototype libary to parse NeXML. TOOD: extract to a separate repo until demand required.

## nomenclature_catalog
TODO: Used? Belongs in /catalog if so.

## paperclip_processors
TODO: Move to vendor. Config/tools for the gem paperclip.

## queries
Libraries to faciliate building complex quieries in TaxonWorks. See README.md

## soft_validation
The underlying models and code for managing soft validations.  Candidate for Gem extraction as it matures.  In it's 3rd "version". 

## tasks
Ruby rake tasks.  Many tools for managing TaxonWorks from the command line, including initialization, reporting, database handling, updates.  Contains some legacy import scripts that will be removed.

## taxonworks
The version of TaxonWorks.

## tools
Code that largely manages complex state space, e.g. an interactive key engine, rather than facilitating rendering (eg. lib/catalog/).

## utilities
Rails *agnostic* (i.e. no Rails methods should be here, though some still need purgin) code that operates on things like Strings etc.  All of these should be candidates for external libraries.

## vendor
Configuration and tools that make use of external Gems or libraries.
