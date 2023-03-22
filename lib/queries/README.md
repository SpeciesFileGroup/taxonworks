These are the primary filtering, and autocomplete queries.  The directory is being re-organized to:

* [ ] Refactor all model specific files into their own directory
* [ ] Inherit, where possible from Queries::Query
* [ ] Dry scopes
* [ ] Factor out shared Arel/query elements to named includes for Queryies::Query

# Design guidelines

* Directory name (/lib/queries/<directory>/) must `.safe_constantize` to an existing ActiveRecord model
  * If name does not .safe_constantize then class must provide `.table` and `.query_base` methods.
* All references to ActiveRecord models must begin with `::`, e.g. `::Otu.all`

## Filter queries

* the `#all` returns a _Scope_

## Autocomplete queries

* should have an `#autocomplete` method that returns an _Array_ 

## Routes

* filter queries should be hit on JSON requests to :index (e.g. `/otus.json?<params>`)
* autocomplete queries should be hit on `/<model>/autocomplete`

## Parameter names

* Array parameters should be singular, like `taxon_name_id[]=`.  This needs to be made consistent throughout.