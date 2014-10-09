Directory Organization
======================

Directories follow standard Rspec conventios, see here: https://www.relishapp.com/rspec/rspec-rails/docs/directory-structure. There is one exception to the example directory layout, our /lib tests are all in /lib, rather than spec/.

Everything else is support for tests.

* **files** contain data files used for testing
* **fixtures** at present only VCR files (wraps API calls out)
* **factories** FactoryGirl factories.  Every AR model has a model and valid_model factory at minimum.
* **support** methods used in multiple tests, including wrappers for each of types 
