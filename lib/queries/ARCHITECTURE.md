# Architecture

## Filter
Query logic within TaxonWorks has largely moved to filters. Filters correspond 1:1 with models in most cases.
Filters work by merging `and` (e.g. `table[:id].in(otu_id)`) and `merge` (e.g. `::Otu.joins(:taxon_name).where(taxon_names: {name: 1})`) clauses together into multi-faceted quries. In many cases results of one Filter can be passed on to a next.

### Conventions

* `And` and `merge` clauses can be identifies as by the post-fix `_facet` on their names
* All `_id` params are singular, regarless as to whether the accept an Array
* `Filter#all` returns a set: one row per record, never ordered or paged. See "Sorting and paging".

### Default facets
There are several near "global" facets that are applied to all filters for example
`model_id_facet` takes all references to variables like `otu_id` and turns them into `table[:id].in(otu_id)`,
and `project_id_facet` applies project_id.  These defaults live in `Queries::Filter`.

### Concerns
Filters have concerns where sharing facets is of use. `And` and `merge` clauses (sets of facets) are automatically applied to the filter result.
These facets have corresponding UI elements.

## Sorting and paging
Filters return sets. `Filter#all` never orders or pages. A caller that needs an ordered slice passes the set to `Queries::Pager`; a caller that needs the set (batch updates, counts, `where(id: filter.all)`, `.distinct`, exports) uses `filter.all` and gets no ORDER BY.

set → order → page composes into one SQL query. Each step keeps its contract, so the steps never conflict:

| Step | Takes | Gives | Must not |
|---|---|---|---|
| Filter (`#all`) | params | a set: one row per record, no ORDER BY, no LIMIT | order or page |
| Order (`Queries::<Model>::Sort`) | a set | the same set, ordered | add or remove rows |
| Page (`Queries::Pager`) | an ordered set | a slice | change the order |

* A set with `DISTINCT`, `GROUP BY` or a `from(...)` subquery (see "Use of `.distinct`" below) can't be ordered by joined columns. The pager reduces it to `Model.where(id: set)` before ordering.
* The pager applies the matched `sort` keys (e.g. `sort=-updated_at,repository.name`, capped at `MAX_SORT_KEYS`; unknown keys are ignored), then always `id ASC` as a tiebreak or fallback, then Kaminari `page`/`per`. Anything that truncates goes through the pager, so a page or "first N" is always in a stable order.
* `recent=true` is shorthand for a leading `-updated_at` key (`-created_at` with `recent_target=created_at`); explicit `sort` keys follow it.
* There is no `paginate` param: the pager always pages.

### Sort keys
Each model declares its keys in `Queries::<Model>::Sort`, in `lib/queries/<model>/sort.rb` next to `filter.rb` and `autocomplete.rb`, using the `Queries::Sort::Resolver` helpers (`direct`, `association`, `custom`, `sortable_direct_columns`, `sortable_association_columns`), each of which returns a `->(query, dir)` sort lambda. `Queries::Sort::Base` provides `updated_at` and `created_at` for every model.

* Sort on what users see: a display name, not an id. Raw foreign keys are rejected.
* Sort on database values: a column, or a simple aggregate of columns (MIN, first by position, joined as displayed). Don't rebuild Ruby rendering (helpers, `taxonomy`) in SQL; for a cell assembled in Ruby, sort on a simple value it visibly contains (e.g. its taxon, see `Queries::Sort::ObjectOtu`), or offer no sort.
* `User` is not reachable for sorting, except `User#name` as the final column. Sort order leaks information about hidden values, and unlike project data, `User` rows are cross-project and mostly not visible to project members. See the comment on `Queries::Sort::Resolver::BLACKLISTED_CLASSES`.
* Credential-shaped, encrypted, and unorderable (`xml`, `json`) columns are excluded.
* Sort joins must let Postgres drop them from the pagination `COUNT`: join to a primary key, or collapse a `LATERAL` with an aggregate (`MIN`, `(array_agg(... ORDER BY ...))[1]`), never `LIMIT 1`. A `has_one` sort needs a unique index on the target's foreign key (+ type).
* `spec/lib/queries/sort/columns_spec.rb` runs `EXPLAIN` on every key of every `Sort` class, and checks that sorting adds no joins to the count.

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
