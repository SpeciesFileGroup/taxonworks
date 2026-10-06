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
  `restrict_to:` and `limit:` and pass them to `super`.
* That's all, unless the autocomplete delegates to another model's
  autocomplete - see below.

`limit:` is how many results the caller wants. `#limit` returns it, or the
class's `DEFAULT_LIMIT` when nil (`Query::Autocomplete::DEFAULT_LIMIT` unless
overridden). An autocomplete that honours it sets its own `DEFAULT_LIMIT` and
caps `#autocomplete` with `#limit`, never a literal (e.g.
`result.first(limit)`, not `result[0..39]`). A restriction keeps unusable candidates out of an inner
autocomplete's results, but if the inner autocomplete still returns its own,
smaller, default number of candidates the caller can't fill its results (e.g.
20 TaxonNames can't fill 50 biological associations when each name's Otu is
in only one or two). So it travels down with the restriction.

#### Delegating to another model's autocomplete
Use `delegated_autocomplete` (`Query::Autocomplete`), giving it how to build
the inner autocomplete (for a limit) and how to keep the inner results usable
under the restriction (e.g. those that map to an `apply_restriction` record,
one query). See `Queries::Otu::Autocomplete#taxon_name_autocomplete`.

It does not translate the restriction for the inner model (e.g. Otus -> the
TaxonNames, and Combinations, they resolve to). That translation is
relation-specific and easy to get subtly wrong, and pushing it into each of
the inner autocomplete's queries is expensive for large restrictions (see
Cost). Instead the inner autocomplete is run once, unrestricted,
`DELEGATED_DEPTH` (5000) deep, and its results filtered. Best effort: usable
matches ranked below that depth - the least relevant - are missed. A LIMIT
costs nothing for terms that match fewer rows, so only broad terms (short
prefixes) pay for the depth; one deep fetch was faster overall than
starting shallower and deepening when too few were kept, with identical
results.

The inner autocomplete must (once, then every caller can use it):
* accept `limit:` and limit each of its queries with it,
* give its queries that can return many rows a ranking ORDER BY of their
  own, so that the first `DELEGATED_DEPTH` are the best ranked (the first N
  of an unordered query are an arbitrary N). Ties don't matter: tied rows
  are equally ranked. Don't add an order just for determinism - an id order
  with a limit can make PostgreSQL walk the primary key instead of using the
  match (wildcard identifier queries went from ~10ms to ~2s).

See `Queries::TaxonName::Autocomplete`.

The exception is when the delegating autocomplete consumes the inner
autocomplete's individual queries rather than its results, as
`Queries::BiologicalAssociation::Autocomplete` does (joining each to
biological associations). Then translate the restriction for the inner
model and pass it on, e.g. Otus that are the *subject* of a restricted BA
for subject matching (`#side_restriction`).

#### Cost
`apply_restriction` adds `id IN (<restrict_to>)` to every query it is
applied to, and PostgreSQL generally evaluates the whole restriction for
each. An autocomplete chain runs dozens of queries, so the restriction's
cost is paid dozens of times, and it grows with the size of the restriction,
not with the number of matching records. Restrictions on an autocomplete's
own queries are generally fine; a large restriction translated down a
delegation chain is what `delegated_autocomplete` avoids (2-6x faster for
biological association autocomplete in large projects).

When the caller can cheaply tell its restriction is small (a few hundred
ids), pass literal ids, `::BiologicalAssociation.where(id: ids)` (still a
relation of the referenced model), rather than the subquery: 3-7x faster
when the restriction is pushed into many queries. See
`Queries::AssertedDistribution::Autocomplete#autocomplete_biological_association`,
which plucks at most `LITERAL_RESTRICTION_MAX` ids and otherwise passes the
subquery. This is deliberately the caller's choice, not `apply_restriction`'s:
checking the size of a large restriction at every level of a chain costs
more than it saves (2-5x slower biological association autocomplete).

#### Keep the ranking
When candidates are turned into results by a join (e.g. Otus -> the
biological associations they are in), order the results by candidate rank
(e.g. `array_position(ARRAY[<ids>], otus.id)`). Otherwise the database
returns them in arbitrary order, and the caller's result limit keeps an
arbitrary subset instead of the best matches. See
`Queries::BiologicalAssociation::Autocomplete#joined_matches`.
