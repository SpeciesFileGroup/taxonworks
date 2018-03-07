Directory Organization
======================

Tests
-----

Directories follow standard [Rspec conventions](https://www.relishapp.com/rspec/rspec-rails/docs/directory-structure). 
There is one exception to the example directory layout, our /lib tests are all in /spec/lib, rather than /spec.  
In addition meta-tests (tests on models, factories, etc. that otherwise don't fit into one of the categories above) are in **taxonworks**.

Support
-------

Everything else is support for tests.


* **taxonworks** meta-tests 
* **files** contain data files used for testing
* **fixtures** at present only VCR files (wraps API calls out)
* **factories** FactoryBot factories.  Every AR model has a model and `valid_` version of the model factory at minimum.
* **support** methods used in multiple tests, including wrappers for each of Controllers, Views, Models, Features, Helpers. 
* **validators** -- ?

