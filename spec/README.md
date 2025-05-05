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

## Guidelines
_The following will have exceptions, however they should be the exception._

* If you see `init_housekeeping` then the specs need refactoring.  Don't use this method for new specs.
* It is more than OK to sacrifice initialization speed and DRYness for clarity, immediacy and an ability to refactor. Finding a balance is a bit of an art form, over time the ability to quickly conceptualize what is being tested becomes more important.
  - `Clarity` - Single specify statements more or less read linearly as stories.
  - `Immediacey` - Consider defining the whole story/context within the specify block.
  - `Ability to Refactor` - In complex scenarios resist the desire to nest expectations, in general 1 expectation per specification. While this is more costly to initialize, it lets you test from multiple directions during complex scenarios. This often means repeated code, to get you one step further in the specification, but it lets you ensure downstream steps work while upstream don't, and vice versa.
* Don't leave in specifications that you can assume to be true during downstream tests. For example using `expect (foo.valid?).to be_falsey` is not necessary if followed by an expectation of *why* it is falsey. Practically you might include the redundant expectation to ensure initial configuration, then remove it when the specific context is in place, before committing. 
*  Do not use `@` variables in specs, they "leak", and lead to many downstream refactoring issues. Pull requests with them in place will almost certainly be asked to refactor.  If you see legacy `@` variables please consider refactoring them.  
* Do not set `Current.<user_id|project_id>` in specs. See config, and init methods.
* Your specs should not require custom database `Cleaner`. This is code smell that suggests deviations from the rspec init/config patterns that will lead to costly downstream refactorization when they are forced on us.

## Tag groups
_E.g. `rspec -t group:nomenclature`

Groups are named in the convention:
* lowercase, singular 

See [here](http://elementalselenium.com/tips/60-list-tags) for something to implement.

Existing groups include
_TODO: can we dynamically generate this list, it's incomplete._
* `nomenclature` - nomenclature logic
* `observation_matrix` - matrix logic

