
# Important bits

* *ORDER MATTERS*. Files are read in the order they are listed in the directories.  See also /lib/taxonworks_autoload (which should ultimately be deprecated).

# Organization

* `/` general TaxonWorks specific initializers
* `/vendor` configuration for vendor (typically gem) libraries
* `/constants` TaxonWorks specific constants
* `/constants/_controlled_vocabularies` fixed non-model specific vocabularies that are used as *data* or data validations
* `/constants/app` default models and values for the application (could be reorganized)
* `/constants/model` constants derived from inspecting /app/model properties/attributes, !!these should always be loaded last!!, they depend on the `_controlled_vocabularies` in some cases
