# Branch Review: 4716_ba_ap_selection
**Date:** 2026-02-19
**Scope:** Creating subject and object anatomical parts from names in the object radial BA slice

---

## What the Branch Does

Adds the ability to create Anatomical Parts (APs) — identified by a free-text **name** OR an ontology **URI + URI label** — for both the subject and object sides of a BiologicalAssociation, directly from the object radial's BA slice.

### Entry Points
- A global "With anatomical parts" checkbox teleported to the radial header
- When enabled: two `AnatomicalPartToggleFieldset` fieldsets appear — one for "Subject anatomical part", one for "Related anatomical part"
- Each fieldset contains `CreateAnatomicalPart.vue`, which offers:
  - **"Create new part"**: free-text name (or ontology search → URI + label) + optional preparation type
  - **"Create from existing part"**: pill buttons of project-level AP templates (name or URI)

### Data Flow (Name Path)
1. User types a name → `validNameOrUri` XOR passes (name present, no URI)
2. Component emits `{valid: true, mode: 'new', payload: {name: 'X', ...}}`
3. Composable stores in `subjectAnatomicalPart` / `relatedAnatomicalPart`
4. On "Create": `mapAnatomicalPartAttributesToAssociationSides()` builds `subject_anatomical_part_attributes: {name: 'X'}` or `object_anatomical_part_attributes: {name: 'X'}` respecting the flip state
5. POST to `/biological_associations` routes through `CreateWithAnatomicalParts` service
6. Service creates the AP with an `inbound_origin_relationship` to the origin object, then sets it as the BA subject/object

### Deduplication
Both frontend (`createdBiologicalAssociation` computed) and backend (`matching_anatomical_part_association`) detect existing BAs with matching AP identity + origin, returning `:ok` instead of creating duplicates.

---

## Issues Found

### Bug: Undefined `index` in `deleteItem` call
**File:** `table_anatomical_part_mode.vue:72`
```js
@click="deleteItem(item, index)"
```
`index` is not bound in the `v-for="item in list"` loop. `deleteItem` accepts only `item` and ignores any second argument, so this is functionally harmless — but it's dead code copied from the original `table.vue`.

### Bug: Undefined `softDelete` reference
**File:** `table_anatomical_part_mode.vue:71` (also in `table.vue:48` — pre-existing)
```js
:color="softDelete ? 'primary' : 'destroy'"
```
`softDelete` is never defined. It's always `undefined` → always `'destroy'`. Functionally the delete button correctly shows as destructive, so no user-visible error, but the conditional is dead code.

### Minor: Double load of `anatomicalPartModeList` on session restore
In `biological_relationships_annotator.vue:onBeforeMount`:
1. `loadAnatomicalPartSessionState()` sets `withAnatomicalPartCreation = true` (from session)
2. `if (withAnatomicalPartCreation.value) { loadAnatomicalPartModeList() }` fires immediately
3. Vue then flushes the `watch(withAnatomicalPartCreation)` watcher, which also calls `loadAnatomicalPartModeList()`

Result: two simultaneous identical API calls on mount when AP mode was previously active. Not a correctness issue; last response wins.

### Scalability: `matching_anatomical_part_association` loads all BAs
**File:** `biological_associations_controller.rb:310-323`
```ruby
BiologicalAssociation.where(...).order(:id).detect do |ba| ...
```
This loads all project BAs for the relationship into memory for Ruby-side detection. Could be slow for large projects. Acceptable for now but worth noting.

---

## What Is Working Well

- **Name-based creation**: fully functional for both subject and object sides
- **URI-based creation**: same form, XOR validation enforced in frontend and model
- **Template reuse**: project-level AP templates load and pre-fill form correctly
- **Flip state**: `subjectAnatomicalPartSide()` / `relatedAnatomicalPartSide()` correctly swap the AP attribute keys when the relationship is flipped
- **Taxon determination gating**: CollectionObject/FieldOccurrence related objects require a TD OTU before an AP can be created — enforced in both frontend (`RelatedAnatomicalPartPanel`) and backend (`CreateWithAnatomicalParts`)
- **Deduplication**: name identity and URI identity matching works on both frontend and backend
- **Session persistence**: `withAnatomicalPartCreation`, `enableSubjectAnatomicalPart`, `enableRelatedAnatomicalPart` persist across page refreshes
- **AP mode table**: `AnatomicalPartSubjectSummary` → modal → `table_anatomical_part_mode` shows all subject-AP BAs with pill display and radial buttons
- **`_attributes.json.jbuilder`**: always outputs `subject_anatomical_part` and `object_anatomical_part` when applicable (not behind extend gate) — ensures frontend matching works
- **Tests**: controller specs cover basic creation, TD creation, TD-required failure, and deduplication (both subject and object sides, including lowest-id preference)

---

## Suggested Follow-ups

1. ~~Fix `deleteItem(item, index)` → `deleteItem(item)`~~ ✓ Fixed
2. ~~Remove `softDelete` ternary, hardcode `'destroy'`~~ ✓ Fixed
3. ~~Deduplicate the double `loadAnatomicalPartModeList()` call on mount~~ ✓ Fixed (removed explicit call; watcher handles it)
4. ~~UX gap: no AP context in regular list for object-AP BAs~~ Not an issue — `AnatomicalPart#object_tag` includes name and origin context
