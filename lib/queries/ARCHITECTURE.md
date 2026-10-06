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
`Query::Autocomplete` accepts an optional `restrict_to:` - the set of the
referenced model's records to restrict results to. `nil` (the default) is no
restriction. It must be a relation OF THE REFERENCED MODEL (or a subclass);
any `select` on it is replaced with `select(:id)`. Anything else (a relation
of another model, an Array of ids, ...) raises `ArgumentError`.

When the ids come from another table, wrap them in a relation of the
referenced model. For example,
`Queries::AssertedEnvironment::Autocomplete` matches by object label, so it
runs `Queries::CollectingEvent::Autocomplete` restricted to CollectingEvents
that have asserted environments:

```ruby
collecting_events = ::CollectingEvent.where(
  id: ::AssertedEnvironment
    .where(asserted_environment_object_type: 'CollectingEvent')
    .select(:asserted_environment_object_id)
)

Queries::CollectingEvent::Autocomplete.new(
  query_string, project_id:, restrict_to: collecting_events
).autocomplete
```

Unrestricted, the inner autocomplete can fill its own result limit with
records the caller can't use, crowding out the ones it can. In large projects
this is common (e.g. a genus search matching hundreds of species, few of
which are in a biological association) and the caller silently misses
results.

Implementing it in an autocomplete:
* Call `apply_restriction(query)` where the individual queries are assembled,
  alongside where `project_id` is applied - NOT in `base_query`. Not all
  queries are built from `base_query` (e.g.
  `referenced_klass.joins(:identifiers)`, `k.where(...)` in concerns);
  applying it at assembly covers them all.
* Subclasses with explicit keyword arguments in `initialize` must accept
  `restrict_to:` and pass it to `super`.
* When an autocomplete itself delegates to another model's autocomplete,
  translate the restriction for that model and pass it on, so restrictions
  compose down the chain. `Queries::BiologicalAssociation::Autocomplete`
  translates per side, e.g. Otus that are the *subject* of a restricted BA
  for subject matching (`#side_restriction`).
* Pass `limit:` on with the restriction: how many results the caller wants.
  A restriction keeps unusable candidates out of the inner autocomplete's
  results, but if the inner autocomplete still returns its own (smaller)
  default number of candidates, the caller can't fill its results (e.g.
  20 TaxonNames can't fill 50 biological associations when each name's Otu
  is in only one or two). Subclasses with explicit keyword arguments accept
  `limit:` and pass it to `super`; an autocomplete that delegates uses it
  for the inner autocomplete's limit (nil is the autocomplete's own default).

#### Cost
`apply_restriction` adds `id IN (<restrict_to>)` to every query it is
applied to, and PostgreSQL generally evaluates the whole restriction for
each. An autocomplete chain runs dozens of queries, so the restriction's
cost is paid dozens of times, and it grows with the size of the restriction,
not with the number of matching records.
* Small restrictions: pass literal ids,
  `::BiologicalAssociation.where(id: ids)` (still a relation of the
  referenced model). See `Queries::AssertedDistribution::Autocomplete`,
  which plucks the ids when there are at most `LITERAL_RESTRICTION_MAX` and
  otherwise passes the subquery - literal ids are much faster for a few
  hundred ids, and slower than the subquery for many thousands.
* Large restrictions pushed into many queries: filter candidates instead,
  below.

#### Filtering candidates instead of restricting every query
Rather than restricting each of an inner autocomplete's queries, run it
unrestricted but deeper (e.g. 1000 results instead of 20), then keep the
candidates that satisfy the restriction with ONE query. This costs about
the same as the unrestricted autocomplete.

Keep it exact, not a depth heuristic: a restricted autocomplete returns the
first candidates, in the unrestricted order, that satisfy the restriction.
The kept candidates start with exactly those results unless the deep results
were cut off (reached the depth) before enough candidates were kept - then
fall back to the restricted autocomplete. See
`Queries::Otu::Autocomplete#taxon_name_autocomplete` (TaxonName results,
filtered through the Otu restriction, `TAXON_NAME_DEPTH`).

#### Keep the ranking
When candidates are turned into results by a join (e.g. Otus -> the
biological associations they are in), order the results by candidate rank
(e.g. `array_position(ARRAY[<ids>], otus.id)`). Otherwise the database
returns them in arbitrary order, and the caller's result limit keeps an
arbitrary subset instead of the best matches. See
`Queries::BiologicalAssociation::Autocomplete#joined_matches`.
