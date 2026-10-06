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

### Conventions
* Subclasses with explicit keyword arguments in `initialize` accept
  `restrict_to:` and `limit:` and pass them to `super`.

### Limit (`limit`)
* `#limit` is the `limit:` given, or the class's `DEFAULT_LIMIT`.
* An autocomplete that honours it sets its own `DEFAULT_LIMIT` and caps
  `#autocomplete` with `#limit`, never a literal (`result.first(limit)`, not
  `result[0..39]`).
* An autocomplete that delegates to another passes its `limit` on, with its
  restriction.
* Build queries that run SQL when built (e.g. ones that run another
  autocomplete) only when earlier queries have not filled `#limit`: list
  method names (or thunks) and build each in turn, not an Array of built
  queries. See `Queries::AssertedDistribution::Autocomplete#autocomplete`
  and `Queries::BiologicalAssociation::Autocomplete#ordered_lazy_queries`.

### Restricting results (`restrict_to`)
* `restrict_to:` is a relation of the referenced model (or a subclass), or
  `nil` for no restriction. Anything else raises `ArgumentError`. Wrap ids
  from another table in a relation of the referenced model, e.g.
  `::CollectingEvent.where(id: ...select(:asserted_environment_object_id))`.
* Apply it with `apply_restriction(query)` where the individual queries are
  assembled, alongside `project_id` - not in `base_query`. See
  `Queries::CollectingEvent::Autocomplete#autocomplete`.
* A caller that can cheaply tell its restriction is small may pass literal
  ids (`::Model.where(id: ids)`) instead of a subquery. See
  `Queries::Query::Autocomplete#asserted_object_restriction`.

### Delegating to another model's autocomplete
* Use `delegated_autocomplete(build:, keep:, key:)`, don't translate the
  restriction for the inner model. See
  `Queries::Otu::Autocomplete#taxon_name_autocomplete`.
* An autocomplete creating several delegating autocompletes (e.g. one per
  side) gives them the same `delegated_results` Hash. See
  `Queries::BiologicalAssociation::Autocomplete#side_autocomplete`.
* The inner autocomplete honours `limit:`, and its queries that can return
  many rows have a ranking ORDER BY. Don't add an id tie-breaker: tied rows
  are equally ranked, and an id order with a limit can make PostgreSQL walk
  the primary key instead of using the match.
* Exception: an autocomplete consuming the inner autocomplete's individual
  queries, not its results, translates the restriction and passes it on. See
  `Queries::BiologicalAssociation::Autocomplete#side_restriction`.

### Keep the ranking
* When candidates are turned into results by a join, order by candidate rank
  with `order_by_id_rank(query, column, ids)`. See
  `Queries::BiologicalAssociation::Autocomplete#joined_matches`.

### Asserted objects
* An autocomplete of records asserting something about a polymorphic object
  (e.g. AssertedDistribution, AssertedEnvironment) matches the objects with
  `asserted_object_autocomplete(object_type:, object_autocomplete_class:,
  object_association:)`, don't join the object autocomplete's queries. See
  `Queries::AssertedEnvironment::Autocomplete#autocomplete_object`.
