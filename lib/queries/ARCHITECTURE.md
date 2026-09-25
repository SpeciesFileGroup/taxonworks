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

### Restricting results (`restrict_to`)
`Query::Autocomplete` accepts an optional `restrict_to:` - a relation of the
referenced model, a relation selecting only its ids, or an Array of ids. `nil`
(the default) is no restriction.

Use it when only a subset of the model's records is useful to the caller, most
often when one autocomplete delegates to another. For example,
`Queries::AssertedEnvironment::Autocomplete` matches by object label, so it
runs `Queries::CollectingEvent::Autocomplete` restricted to CollectingEvents
that have asserted environments:

```ruby
ce_ids = ::AssertedEnvironment
  .where(asserted_environment_object_type: 'CollectingEvent')
  .select(:asserted_environment_object_id)

Queries::CollectingEvent::Autocomplete.new(
  query_string, project_id:, restrict_to: ce_ids
).autocomplete
```

Unrestricted, the inner autocomplete:
* pays its full cost over every record (e.g. ~3.7s for a CE autocomplete miss
  over 500k records), and
* can fill its own result limit with records the caller can't use, crowding
  out the ones it can.

Implementing it in an autocomplete:
* Call `apply_restriction(query)` where the individual queries are assembled,
  alongside where `project_id` is applied - NOT in `base_query`. Not all
  queries are built from `base_query` (e.g.
  `referenced_klass.joins(:identifiers)`, `k.where(...)` in concerns);
  applying it at assembly covers them all.
* Subclasses with explicit keyword arguments in `initialize` must accept
  `restrict_to:` and pass it to `super`.
* When an autocomplete itself delegates to another model's autocomplete,
  translate the restriction for that model and pass it on (e.g. Otus -> the
  TaxonNames those Otus use), so restrictions compose down the chain.

Currently implemented in: CollectingEvent, Otu, Gazetteer.
