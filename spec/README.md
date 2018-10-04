Directory Organization
======================

# Tests

Directories follow standard [Rspec conventions](https://www.relishapp.com/rspec/rspec-rails/docs/directory-structure). 
There is one exception to the example directory layout, our /lib tests are all in /spec/lib, rather than /spec.  
In addition meta-tests (tests on models, factories, etc. that otherwise don't fit into one of the categories above) are in **taxonworks**.

# Support

Everything else is support for tests.

* **taxonworks** meta-tests 
* **files** contain data files used for testing
* **fixtures** at present only VCR files (wraps API calls out)
* **factories** FactoryBot factories.  Every AR model has a model and `valid_` version of the model factory at minimum.
* **support** methods used in multiple tests, including wrappers for each of Controllers, Views, Models, Features, Helpers. 
* **validators** -- ?

# Housekeeping and globals

TaxonWorks uses an extremely small set of globals (in Rails 5.2 branch we replace this with `Current`) to set housekeeping.  

See corresponding `/support` for how globals are handled, but in general:

* Model tests wrap the globals in `user_id` and `project_id` accessors
* Feature specs *must never reference the globals*

