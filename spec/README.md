Directory Organization
======================

Tests
-----

Directories follow standard [Rspec conventions](https://www.relishapp.com/rspec/rspec-rails/docs/directory-structure). 
There is one exception to the example directory layout, our /lib tests are all in /spec/lib, rather than /spec.  

Support
-------

Everything else is support for tests.

* **factories** FactoryBot factories. In TW every AR model has at minimum a model named `valid_<model>`.
* **files** contain data files used for testing
* **fixtures** at present only VCR files (wraps API calls out)
* **support** methods used in multiple tests, including wrappers for each of Controllers, Views, Models, Features, Helpers. 
* **taxonworks** meta- and linting-based tests 
* **validators** includes for general purpose data validation
