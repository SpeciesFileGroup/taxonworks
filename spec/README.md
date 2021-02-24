# Specs

## Organization

Directories follow standard [Rspec conventions](https://www.relishapp.com/rspec/rspec-rails/docs/directory-structure). 
There is two exceptions to the example directory layout, our /lib tests are all in /spec/lib, rather than /spec and tests for /config/initializers are in /spec/config. In addition meta-tests (tests on models, factories, etc. that otherwise don't fit into one of the categories above) are in **taxonworks**.

### Support

Everything else is support for tests.

* **factories** FactoryBot factories. In TW every ActiveRecord model has at minimum a model named `valid_<model>`.
* **files** contain data files used for testing
* **fixtures** at present only VCR files (wraps API calls out)
* **support** methods used in multiple tests, including wrappers for each of Controllers, Views, Models, Features, Helpers. 
* **taxonworks** meta- and linting-based tests 
* **validators** includes for general purpose data validation

### API vs. "internal"

By API we refer to request to the path prefixed by `/api/v<n>`.  All other requests are "internal".

* We use `request` specs to test `/api/v<n>/` requests, these all return JSON
* We use `feature` specs in the context of requests _coming from a browser_.  There is a small overlap in API tests here where we demonstrate API calls can also use tokens through the browser.

# Rspec config etc.

## Setup - housekeeping and globals

TaxonWorks uses an extremely small set of "globals" (2) using `Current` to set housekeeping.

See corresponding `/support/projects_and_users.rb` for how globals are handled, but in general:

* Model tests wrap the globals in `user_id` and `project_id` accessors
* `Feature` specs *must never reference the globals*.

## Tag groups

See [here](http://elementalselenium.com/tips/60-list-tags) for something to implement.

## Naming 
Groups are named in the convention:
* lowercase, singular 


### Exisiting 

* `nomenclature` - nomenclature logic
* `observation_matrix` - matrix logic
* 
