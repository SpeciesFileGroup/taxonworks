# Autoselect Architecture

`lib/autoselect/` implements a server-driven, multi-level search framework
for progressive autocomplete fields in the TaxonWorks UI.  Each model gets
its own Autoselect class; the Vue component `AutoselectField.vue` is the
shared client-side consumer.

## Concepts

### Levels
A **level** is a named, independent search strategy for one model.  Levels
are ordered; when a level returns no results the **fuse mechanic** fires and
the next level executes automatically.  The order of the level stack is
declared in each model Autoselect class.

Common built-in level types:
| Type | Class | Description |
|------|-------|-------------|
| Fast | `Autoselect::Level` subclass | Prefix-match on a cached column; no GIN/similarity |
| Smart | `Autoselect::Levels::Smart` | Delegates to `Queries::<Model>::Autocomplete` |
| CatalogOfLife | model-specific | External HTTP call to the CoL API |

A level is `external?` when it reaches outside the local database.  External
levels get a longer default fuse (`EXTERNAL_FUSE_MS = 2000` vs
`DEFAULT_FUSE_MS = 600`).

### Fuse mechanic
When a term search at the current level returns 0 results, the server
includes `next_level` in the response.  The client animates a sweep across
the departing fuse segment and then re-issues the same search at the next
level.  User input cancels the pending escalation.

### Operators
Operators are `!`-prefixed tokens recognized at the start of the input term.
They are defined in `lib/autoselect/operators.rb` and parsed server-side by
`Autoselect::Operators#parse_operators`.

Standard operators (all models):
| Trigger | Key | client_only | Meaning |
|---------|-----|-------------|---------|
| `!u`  | `:recent_mine` | false | Records updated by you in the last week (limit 10) |
| `!r`  | `:recent`      | false | Records updated project-wide in the last week (limit 10) |
| `!?`  | `:help`        | true  | Show help overlay (no server call) |
| `!n`  | `:new_record`  | true  | Open new-record modal (detected anywhere in string) |
| `!e`  | `:external`    | true  | Jump to leftmost external level; no-op if none present |
| `!N`  | `:level_number`| true  | Jump to level N (e.g. `!2`) |

Client-only operators are not sent to the server.  `!n` is server-side:
levels that support it return a sentinel (see **Extensions** below).

Per-model operator customisation: override `operator_map` in the model's
`Operators` module (e.g. `lib/autoselect/otu/operators.rb`).

### Extensions
A result item may carry an `extension` hash that signals the client to open a
secondary UI before completing the selection.  The extension is opaque to the
base class; each model's `format_results` populates it.

Current extension modes:

| `extension` key | Meaning | Client handler |
|-----------------|---------|----------------|
| `col_key: <id>` | CoL result; show creation confirmation table | `ColConfirmModal.vue` |

### Hooks
`Autoselect::Hook` (base class) represents cross-model level chains.  The
canonical case is `Autoselect::Otu::Levels::CatalogOfLife`, which delegates
to `Autoselect::TaxonName::Levels::CatalogOfLife` to obtain a TaxonName
first, then wraps the result for OTU creation.  Hook metadata is embedded in
the `extension.hook` hash sent to the client:

```ruby
{ model: 'TaxonName', level: 'catalog_of_life', yields: 'taxon_name_id' }
```

## Directory layout

```
lib/autoselect/
  autoselect.rb              # namespace module (Zeitwerk compatibility)
  base.rb                    # Autoselect::Base — all model autoselects inherit this
  level.rb                   # Autoselect::Level — base class for all levels
  levels/
    smart.rb                 # Autoselect::Levels::Smart — Queries delegation
  operators.rb               # Autoselect::Operators — parsing + OPERATORS constant
  response.rb                # Autoselect::Response — JSON envelope
  hook.rb                    # Autoselect::Hook — cross-model level chain base

  taxon_name/
    autoselect.rb            # Autoselect::TaxonName::Autoselect (3 levels: fast→smart→CoL)
    operators.rb             # TaxonName operator overrides (currently inherits default)
    levels/
      fast.rb                # Prefix match on cached column
      smart.rb               # Delegates to Queries::TaxonName::Autocomplete
      catalog_of_life.rb     # External CoL search
    col_creator.rb           # TaxonName creation logic from CoL alignment data

  otu/
    autoselect.rb            # Autoselect::Otu::Autoselect (2 levels: smart→CoL)
    operators.rb             # OTU operator overrides (currently inherits default)
    levels/
      smart.rb               # Delegates to Queries::Otu::Autocomplete; handles !n sentinel
      catalog_of_life.rb     # Delegates to TaxonName CoL level; wraps with hook metadata
```

## Request / response flow

```
Client (AutoselectField.vue)
  │
  ├─ GET /otus/autoselect          (no term)  → config response
  │     levels[], operators[], map[]
  │
  └─ GET /otus/autoselect?term=X&level=smart  → term response
        response: [ { id, label, label_html, info, response_values, extension } ]
        next_level: 'catalog_of_life'   (only when response is empty)
```

**Config response** (no term sent):
```json
{
  "resource": "/otus/autoselect",
  "levels": [ { "key": "smart", "label": "Smart", "external": false, "fuse_ms": 600 }, ... ],
  "operators": [ { "key": "new_record", "trigger": "!n", ... }, ... ],
  "map": ["smart", "catalog_of_life"]
}
```

**Term response**:
```json
{
  "request": { "term": "Homo", "level": "smart" },
  "level": "smart",
  "response": [ { "id": 1, "label": "Homo sapiens", "response_values": { "otu_id": 1 }, "extension": {} } ],
  "next_level": "catalog_of_life"   // omitted when results present
}
```

## Implementing a new model autoselect

1. `rails generate taxon_works:autoselect <Model> [levels...] [--fast] [--no-example]`
   - Level names **before** flag args: `rails g taxon_works:autoselect Otu smart catalog_of_life`
2. The generator creates:
   - `lib/autoselect/<model>/autoselect.rb`
   - `lib/autoselect/<model>/operators.rb`
   - `lib/autoselect/<model>/levels/<level>.rb` for each level
3. Add a route: `get 'autoselect', on: :collection` inside the model's resources block.
4. Add a controller action delegating to the Autoselect class.
5. Write a spec in `spec/lib/autoselect/<model>/`.

## Key conventions

- `lib/autoselect.rb` is a **namespace module** only — no class body — to
  satisfy Zeitwerk without a constant clash.
- `lib/generators/` is **excluded** from Zeitwerk; generator files must
  `require 'rails/generators'` explicitly.
- In spec files under `lib/`, use `FactoryBot.create(...)` not bare
  `create(...)` (FactoryBot helpers are not globally included in lib specs).
- Use `::Autoselect::Operators::OPERATORS` (leading `::`) inside
  model-specific operators modules to avoid constant-lookup ambiguity.
- Operator order in `OPERATORS` matters: more specific patterns first
  (`:recent_mine` before `:recent` so `!rm` is not consumed by `!r`).

## Client-side components

| File | Purpose |
|------|---------|
| `app/javascript/vue/components/ui/AutoselectField.vue` | Main autocomplete input with fuse bar, dropdown, operator handling, extension panels |
| `app/javascript/vue/components/ui/AutoselectField/useAutoselect.js` | Composable: config fetch + cache, level/operator helpers |
| `app/javascript/vue/components/ui/AutoselectField/ColConfirmModal.vue` | CoL TaxonName creation confirmation modal |
| `app/javascript/vue/components/ui/AutoselectField/TaxonWorksSpinner.vue` | 16 px spinning TaxonWorks logo (internal levels) |
| `app/javascript/vue/components/ui/AutoselectField/CatalogueOfLifeSpinner.vue` | 16 px pulsing CoL colour squares (external levels) |

The `!n` (new_record) operator is **fully client-side** (`client_only: true`).
It is detected anywhere in the input string (e.g. `zzz !n` triggers with name
prefill `zzz`).  The operator and surrounding whitespace are stripped; the
remainder becomes the pre-filled OTU Name.  The modal opens immediately with
no server round-trip.  A secondary `GET /taxon_names/autocomplete?exact=true`
search pre-populates the TaxonName autocomplete when exactly one match is
found, or presents a radio-button disambiguation list when multiple matches
exist.  Selecting a TaxonName collapses the list.  On Create, a `POST /otus`
is issued and the new OTU is selected as if chosen from the dropdown.
