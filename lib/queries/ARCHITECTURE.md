# Architecture

## Filter
Query logic within TaxonWorks has largely moved to filters. Filters correspond 1:1 with models in most cases.
Filters work by merging `and` (e.g. `table[:id].in(otu_id)`) and `merge` (e.g. `::Otu.joins(:taxon_name).where(taxon_names: {name: 1})`) clauses together into multi-faceted quries. In many cases results of one Filter can be passed on to a next.

### Conventions

* `And` and `merge` clauses can be identifies as by the post-fix `_facet` on their names
* All `_id` params are singular, regarless as to whether the accept an Array

### Default facets
There are several near "global" facets that are applied to all filters for example
`model_id_facet` takes all references to variables like `otu_id` and turns them into `table[:id].in(otu_id)`,
and `project_id_facet` applies project_id.  These defaults live in `Queries::Filter`.

### Concerns
Filters have concerns where sharing facets is of use. `And` and `merge` clauses (sets of facets) are automatically applied to the filter result.
These facets have corresponding UI elements.

### Sorting
Filters accept a multi-column `sort` param (e.g. `sort=-updated_at,repository.name`), capped at `MAX_SORT_KEYS`; unknown keys are ignored.
Each filter whitelists its keys in `sortable_columns_uncached`, usually in its own `sortable_filter_columns.rb`, using the `Queries::Concerns::SortResolver` DSL (`direct`, `assoc`, `custom`, `sortable_direct_columns`, `sortable_assoc_columns`).

* Sort on what users see: a display name, not an id. Raw foreign keys are rejected.
* `User` is not reachable for sorting, except `User#name` as the final column. Sort order leaks information about hidden values, and unlike project data, `User` rows are cross-project and mostly not visible to project members. See the comment on `BLACKLISTED_CLASSES`.
* Credential-shaped, encrypted, and unorderable (`xml`, `json`) columns are excluded.
* Sort joins must let Postgres drop them from the pagination `COUNT`: join to a primary key, or collapse a `LATERAL` with an aggregate (`MIN`, `(array_agg(... ORDER BY ...))[1]`), never `LIMIT 1`. A `has_one` sort needs a unique index on the target's foreign key (+ type).
* `spec/lib/queries/sortable_columns_spec.rb` runs `EXPLAIN` on every key of every filter, and checks that sorting adds no joins to the count.

###  Use of `.distinct`
The `.distinct` clause should be assigned at the facet level, if necessary.  We've removed it at the final stage primarily because `.distinct` doesn't work on our current JSON storage formats. Once we migrate them to JSONB (perhaps), we could return to using distinct at the `.all` level, which would be preferred.

#### Adding a UI element
To add the corresponding facet to a filter do the following in the corresponding FilterVue.vue, (e.g. `app/javascript/vue/tasks/otu/filter/components/FilterVue.vue`):

1- Import the facet:

`import FacetUsers from 'components/Filter/Facets/shared/FacetUsers.vue'`

2- Add it to the layout in the position you want it to appear:

`<FacetUsers v-model="params" />`

### With/out facets

To add a corresponding With/Out facet in the UI add it
to the corresponding WITH_PARAM.  Then add a `boolean_param()`,
with the exact same name, to the filter. E.g.:

```javascript
// .js
const WITH_PARAM = [ 'citations' ];
```

```ruby
attr_accessor :citations
# ...
@citations = boolean_param(params, :citations)
# ...
def citations_facet
# filter logic
end
```

## Autocomplete
TODO:
