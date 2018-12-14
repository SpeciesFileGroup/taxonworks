Directory Organization
======================

# Tests

Directories follow standard [Rspec conventions](https://www.relishapp.com/rspec/rspec-rails/docs/directory-structure). 
There is two exceptions to the example directory layout, our /lib tests are all in /spec/lib, rather than /spec and tests for /config/initializers are in /spec/config. In addition meta-tests (tests on models, factories, etc. that otherwise don't fit into one of the categories above) are in **taxonworks**.

# Support

Everything else is support for tests.

* **factories** FactoryBot factories. In TW every AR model has at minimum a model named `valid_<model>`.
* **files** contain data files used for testing
* **fixtures** at present only VCR files (wraps API calls out)
* **support** methods used in multiple tests, including wrappers for each of Controllers, Views, Models, Features, Helpers. 
* **taxonworks** meta- and linting-based tests 
* **validators** includes for general purpose data validation

# Housekeeping and globals

TaxonWorks uses an extremely small set of globals (in Rails 5.2 branch we replace this with `Current`) to set housekeeping.  

See corresponding `/support` for how globals are handled, but in general:

* Model tests wrap the globals in `user_id` and `project_id` accessors
* Feature specs *must never reference the globals*

