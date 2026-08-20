<template>
  <div class="margin-medium-top">
    <VSpinner
      v-if="isProcessing"
      full-screen
      legend="Matching names..."
    />

    <InputPanel
      v-if="stage === 'input'"
      @submit="handleDataSubmit"
    />

    <template v-if="stage === 'results'">
      <div class="flex-row align-start gap-medium">
        <div class="flex-col gap-medium left-column">
          <div class="panel content reset-panel">
            <div class="flex-row flex-separate middle">
              <VBtn
                circle
                color="primary"
                title="Reset task"
                @click="reset"
              >
                <VIcon
                  x-small
                  name="reset"
                />
              </VBtn>
            </div>

            <div class="margin-small-top">
              <label
                class="middle"
                data-help="Also matches scientificNames against an existing OTU's genus + otu_name (e.g. a morphospecies code like 'Tapinoma CASC_2231') - exact match only, two words, no fuzzy matching."
              >
                <input
                  type="checkbox"
                  v-model="matchOtuNames"
                  @change="handleOptionsChange"
                />
                Match to both taxon names and otus
              </label>
            </div>
          </div>

          <MatchOptionsPanel
            class="sticky-panel"
            v-model:scope-taxon-name="scopeTaxonName"
            v-model:levenshtein-distance="levenshteinDistance"
            v-model:try-without-subgenus="tryWithoutSubgenus"
            v-model:resolve-synonyms="resolveSynonyms"
            v-model:modifiers="modifiers"
            @clear-all="clearAllMatches"
            @update-options="handleOptionsChange"
          />
        </div>

        <div class="flex-row align-start gap-medium full_width">
          <div class="full_width">
            <SummaryBar
              v-if="rows.length"
              :rows="rows"
              :filtered-rows="visibleRows"
            />

            <ResultTable
              :rows="visibleRows"
              :csv-data="csvData"
              :match-otu-names="matchOtuNames"
              v-model:taxon-name-filter="taxonNameFilter"
              v-model:otu-filter="otuFilter"
              @update-row="handleRowUpdate"
              @create-otu="handleCreateOtu"
              @create-morphospecies-otu="handleCreateMorphospeciesOtu"
              @scroll-to-row="scrollToRow"
              @match-row="handleMatchRow"
            />
          </div>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup>
import { computed, ref, watch, onMounted } from 'vue'
import { TaxonName, Otu } from '@/routes/endpoints'
import VSpinner from '@/components/ui/VSpinner.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import InputPanel from './components/InputPanel.vue'
import ResultTable from './components/ResultTable.vue'
import SummaryBar from './components/SummaryBar.vue'
import MatchOptionsPanel from './components/MatchOptionsPanel.vue'
import { MAX_ROWS, TAXON_NAME_FILTER, OTU_FILTER, defaultModifiers } from './constants.js'
import effectiveName from './utils/effectiveName.js'
import sortOtus from './utils/sortOtus.js'

defineOptions({
  name: 'MatchOtuByTaxonName'
})

const stage = ref('input') // 'input' or 'results'
const isProcessing = ref(false)
const rows = ref([])
const csvData = ref(null)
const taxonNameFilter = ref(TAXON_NAME_FILTER.All)
const otuFilter = ref(OTU_FILTER.All)

function matchesTaxonNameFilter(row) {
  if (taxonNameFilter.value === TAXON_NAME_FILTER.Ambiguous) {
    return row.matched && row.ambiguous
  }
  if (taxonNameFilter.value === TAXON_NAME_FILTER.Unmatched) {
    return !row.matched
  }
  if (taxonNameFilter.value === TAXON_NAME_FILTER['Matched TNs']) {
    return row.matchSource === 'taxon_name' || row.matchSource === 'both'
  }
  if (taxonNameFilter.value === TAXON_NAME_FILTER['Matched OTUs']) {
    return row.matchSource === 'otu' || row.matchSource === 'both'
  }
  return true
}

function matchesOtuFilter(row) {
  if (otuFilter.value === OTU_FILTER['Multiple OTUs']) {
    return row.otus.length > 1
  }
  if (otuFilter.value === OTU_FILTER['User selected']) {
    return row.fixedOtuId != null
  }
  if (otuFilter.value === OTU_FILTER['No OTU']) {
    return row.selectedOtuId == null
  }
  return true
}

// The set of rows a filter selects is captured once, when the filter is applied - not
// recomputed live - so a background re-match can't cause rows to disappear out from under the
// user mid-review. The rows themselves stay reactive: their content (match status, OTU, etc.)
// still updates live, only set membership is frozen until the filter changes again.
const visibleRowIndices = ref(null) // null: no filter active, show every row live

function snapshotVisibleRowIndices() {
  if (taxonNameFilter.value === TAXON_NAME_FILTER.All && otuFilter.value === OTU_FILTER.All) {
    visibleRowIndices.value = null
    return
  }

  visibleRowIndices.value = new Set(
    rows.value
      .filter((row) => matchesTaxonNameFilter(row) && matchesOtuFilter(row))
      .map((row) => row.index)
  )
}

watch([taxonNameFilter, otuFilter], snapshotVisibleRowIndices)

const visibleRows = computed(() =>
  visibleRowIndices.value === null
    ? rows.value
    : rows.value.filter((row) => visibleRowIndices.value.has(row.index))
)

const scopeTaxonName = ref()
const levenshteinDistance = ref(0)
const tryWithoutSubgenus = ref(false)
const resolveSynonyms = ref(false)
const matchOtuNames = ref(false)

const modifiers = ref(defaultModifiers())

// The scope the task was actually launched with (via ?taxon_name_id=), so
// Restart/Reset can return to it instead of always clearing to no scope.
const initialScopeTaxonName = ref(null)

onMounted(() => {
  const urlParams = new URLSearchParams(window.location.search)
  const taxonNameId = urlParams.get('taxon_name_id')

  if (taxonNameId) {
    TaxonName.find(taxonNameId)
      .then(({ body }) => {
        scopeTaxonName.value = body
        initialScopeTaxonName.value = body
      })
      .catch(() => {})
  }
})

async function handleDataSubmit({ names, csv }) {
  isProcessing.value = true
  // Give the browser enough time to paint the spinner before it gets bogged
  // down in processing.
  await new Promise((resolve) => setTimeout(resolve, 0))

  csvData.value = csv

  rows.value = names.slice(0, MAX_ROWS).map((name, index) => {
    const isEmpty = !name || !name.trim()
    return {
      index,
      scientificName: isEmpty ? '' : name,
      regexMatchString: '',
      userMatchString: '',
      taxonName: null,
      taxonNameId: null,
      otus: [],
      selectedOtuId: null,
      fixedOtuId: null,
      fixedOtuName: null,
      ambiguous: false,
      matched: false,
      matchSource: null,
      selected: false,
      isEmpty,
      csvRow: csv ? csv.rows[index] : null
    }
  })

  stage.value = 'results'

  handleOptionsChange()
}

function applyModifiers(name) {
  let result = name

  for (const modifier of modifiers.value) {
    if (!modifier.active || !modifier.pattern) continue

    try {
      const regex = new RegExp(modifier.pattern, 'g')
      result = result.replace(regex, modifier.replacement || '')
    } catch {
      // Invalid regex, skip
    }
  }

  return result.trim()
}

function scopedRows() {
  const checked = rows.value.filter((r) => r.selected && !r.isEmpty)
  return checked.length ? checked : visibleRows.value.filter((r) => !r.isEmpty)
}

function applyModifiersToRows(targetRows) {
  const hasActiveModifier = modifiers.value.some((m) => m.active && m.pattern)
  targetRows.forEach((row) => {
    row.regexMatchString = hasActiveModifier ? applyModifiers(row.scientificName) : ''
  })
}

async function handleOptionsChange() {
  const target = scopedRows()
  applyModifiersToRows(target)
  await matchRows(target)
}

async function handleMatchRow({ index }) {
  const row = rows.value[index]
  if (!row || row.isEmpty) return
  await matchRows([row])
}

async function matchRows(targetRows) {
  syncAllDuplicates()
  if (!targetRows.length) return

  const nameMap = new Map()

  targetRows.forEach((row) => {
    const name = effectiveName(row)
    if (!nameMap.has(name)) {
      nameMap.set(name, [])
    }
    nameMap.get(name).push(row)
  })

  const uniqueNames = [...nameMap.keys()]

  isProcessing.value = true

  try {
    const { body } = await TaxonName.match({
      names: uniqueNames,
      levenshtein_distance: levenshteinDistance.value,
      taxon_name_id: scopeTaxonName.value?.id,
      resolve_synonyms: resolveSynonyms.value ? 'true' : 'false',
      try_without_subgenus: tryWithoutSubgenus.value ? 'true' : 'false',
      match_otu_names: matchOtuNames.value ? 'true' : 'false'
    })

    body.forEach((result) => {
      const matchedRows = nameMap.get(result.scientific_name)
      if (!matchedRows) return

      const otus = sortOtus(result.otus || [])

      matchedRows.forEach((row) => {
        applyMatchResult(row, {
          taxonName: result.taxon_name,
          taxonNameId: result.taxon_name_id,
          otus,
          selectedOtuId: otus.length ? otus[0].id : null,
          ambiguous: result.ambiguous,
          matched: result.matched,
          matchSource: result.match_source
        })
      })
    })
  } catch (e) {
    TW.workbench.alert.create('Error matching names.', 'error')
  } finally {
    syncAllDuplicates()
    isProcessing.value = false
  }
}

function handleRowUpdate({ index, field, value }) {
  const row = rows.value[index]
  if (!row) return

  if (field === 'taxonName') {
    if (value) {
      // The autoselect result doesn't include cached_html
      // (only label/label_html, meant for the dropdown itself), so re-fetch the
      // full record for display.
      refreshTaxonNameSelection(value.id, row)
    } else {
      applyMatchResult(row, {
        taxonName: null,
        taxonNameId: null,
        otus: [],
        selectedOtuId: null,
        ambiguous: false,
        matched: false,
        matchSource: null
      })
      syncDuplicateRows(row)
    }
  } else if (field === 'otuRefine') {
    if (value) {
      // The autoselect result doesn't include the OTU's genus TaxonName
      // (only label/label_html, meant for the dropdown itself), so re-fetch
      // both full records for display.
      refreshOtuRefineSelection(value.id, row)
    } else {
      // Cleared - behaves like unlocking a fixed OTU (see 'fixedOtuId' below).
      row.fixedOtuId = null
      row.fixedOtuName = null
      matchRows([row])
    }
  } else if (field === 'userMatchString') {
    row.userMatchString = value
  } else if (field === 'selected') {
    row.selected = value
  } else if (field === 'selectedOtuId') {
    // A radio click explicitly fixes the OTU: it survives subsequent
    // re-matches (e.g. toggling match options) until reset.
    row.fixedOtuId = value.id
    row.fixedOtuName = value.object_label || value.name || `OTU ${value.id}`
    row.selectedOtuId = value.id
    syncDuplicateRows(row)
  } else if (field === 'fixedOtuId') {
    // Unlocking a fixed OTU: re-match the row so its taxonName/otus/matched
    // status reflect the current match options instead of the stale state
    // from before it was fixed.
    row.fixedOtuId = value
    row.fixedOtuName = null
    matchRows([row])
  }
}

async function refreshTaxonNameSelection(taxonNameId, row) {
  isProcessing.value = true

  try {
    const [taxonName, otus] = await Promise.all([
      fetchTaxonName(taxonNameId),
      fetchOtusForTaxonName(taxonNameId)
    ])

    applyMatchResult(row, {
      taxonName,
      taxonNameId,
      otus,
      selectedOtuId: otus.length ? otus[0].id : null,
      ambiguous: false,
      matched: true,
      matchSource: 'taxon_name'
    })

    syncDuplicateRows(row)
  } catch (e) {
    TW.workbench.alert.create(
      'Error loading TaxonName/OTU details.',
      'error'
    )
  } finally {
    isProcessing.value = false
  }
}

// A manual OTU Refine pick: locks the row to that specific OTU (like a radio-click
// fix) and shows its genus TaxonName in the Match result column.
async function refreshOtuRefineSelection(otuId, row) {
  isProcessing.value = true

  try {
    const { body: otu } = await Otu.find(otuId)
    const taxonName = await fetchTaxonName(otu.taxon_name_id)

    applyMatchResult(row, {
      taxonName,
      taxonNameId: otu.taxon_name_id,
      otus: [{
        id: otu.id,
        name: otu.name,
        taxon_name_id: otu.taxon_name_id,
        object_label: otu.object_label
      }],
      selectedOtuId: otu.id,
      ambiguous: false,
      matched: true,
      matchSource: 'otu'
    })

    row.fixedOtuId = otu.id
    row.fixedOtuName = otu.object_label || otu.name || `OTU ${otu.id}`

    syncDuplicateRows(row)
  } catch (e) {
    TW.workbench.alert.create('Error loading OTU/TaxonName details.', 'error')
  } finally {
    isProcessing.value = false
  }
}

async function fetchTaxonName(taxonNameId) {
  const { body } = await TaxonName
    .find(taxonNameId)
    .catch(() => {})

  return body
}

async function fetchOtusForTaxonName(taxonNameId) {
  const { body } = await TaxonName
    .otus(taxonNameId)
    .catch(() => {})

  return sortOtus(body.map((o) => ({
    id: o.id,
    name: o.name,
    taxon_name_id: o.taxon_name_id,
    object_label: o.object_label
  })))
}

async function handleCreateOtu({ index }) {
  const row = rows.value[index]
  if (!row?.taxonNameId) return

  try {
    const { body } = await Otu
      .create({
        otu: { taxon_name_id: row.taxonNameId }
      })
      .catch(() => {})

    const newOtu = {
      id: body.id,
      name: body.name,
      taxon_name_id: body.taxon_name_id,
      object_label: body.object_label
    }

    row.otus.push(newOtu)
    row.fixedOtuId = newOtu.id
    row.fixedOtuName = newOtu.object_label || newOtu.name || `OTU ${newOtu.id}`
    row.selectedOtuId = newOtu.id
    row.matchSource = 'taxon_name'

    syncDuplicateRows(row)
    TW.workbench.alert.create('OTU created successfully.', 'notice')
  } catch (e) {
    TW.workbench.alert.create('Failed to create OTU.', 'error')
  }
}

// Creates the Otu for an exact "Genus otu_name" pair, independent of whatever
// TaxonName may or may not already be matched for this row.
async function handleCreateMorphospeciesOtu({ index }) {
  const row = rows.value[index]
  if (!row) return

  try {
    const { body } = await Otu.createMorphospeciesOtu({ name: effectiveName(row) })

    const newOtu = {
      id: body.otu_id,
      name: body.otu_name,
      taxon_name_id: body.taxon_name_id,
      object_label: body.otu_object_label
    }
    const taxonName = {
      id: body.taxon_name_id,
      cached: body.taxon_name_cached,
      cached_html: body.taxon_name_cached_html,
      global_id: body.taxon_name_global_id,
      object_label: body.taxon_name_object_label
    }

    applyMatchResult(row, {
      taxonName,
      taxonNameId: body.taxon_name_id,
      otus: [newOtu],
      selectedOtuId: newOtu.id,
      ambiguous: false,
      matched: true,
      matchSource: 'otu'
    })

    row.fixedOtuId = newOtu.id
    row.fixedOtuName = newOtu.object_label || newOtu.name

    syncDuplicateRows(row)
    TW.workbench.alert.create('OTU created successfully.', 'notice')
  } catch (e) {
    TW.workbench.alert.create(
      e?.response?.data?.error || 'Failed to create OTU.',
      'error'
    )
  }
}

// A row.fixedOtuId (set by an explicit radio click) survives a re-applied
// otus list regardless of whether the new list still contains it.
function resolveSelectedOtuId(row, defaultSelectedOtuId) {
  return row.fixedOtuId ?? defaultSelectedOtuId
}

function applyMatchResult(row, source) {
  row.taxonName = source.taxonName
  row.taxonNameId = source.taxonNameId
  row.otus = source.otus
  row.selectedOtuId = resolveSelectedOtuId(row, source.selectedOtuId)
  row.ambiguous = source.ambiguous
  row.matched = source.matched || row.fixedOtuId != null
  row.matchSource = source.matchSource ?? null
}

function syncDuplicateRows(sourceRow) {
  const sourceName = effectiveName(sourceRow)

  rows.value.forEach((row) => {
    if (row.index === sourceRow.index) return

    if (effectiveName(row) === sourceName) {
      row.fixedOtuId = sourceRow.fixedOtuId
      row.fixedOtuName = sourceRow.fixedOtuName
      applyMatchResult(row, sourceRow)
    }
  })
}

// After match operations, ensure all rows with identical effective names
// share the same match data from the first occurrence (the actionable row).
function syncAllDuplicates() {
  const seen = new Map()

  rows.value.forEach((row) => {
    if (row.isEmpty) return

    const name = effectiveName(row)
    if (!seen.has(name)) {
      seen.set(name, row)
    } else {
      const source = seen.get(name)
      row.fixedOtuId = source.fixedOtuId
      row.fixedOtuName = source.fixedOtuName
      applyMatchResult(row, source)
      row.selected = false
    }
  })
}

function resetMatchOptions() {
  scopeTaxonName.value = initialScopeTaxonName.value
  levenshteinDistance.value = 0
  tryWithoutSubgenus.value = false
  resolveSynonyms.value = false
  matchOtuNames.value = false
  modifiers.value = defaultModifiers()
}

function clearAllMatches() {
  resetMatchOptions()
  taxonNameFilter.value = TAXON_NAME_FILTER.All
  otuFilter.value = OTU_FILTER.All

  rows.value.forEach((row) => {
    row.taxonName = null
    row.taxonNameId = null
    row.otus = []
    row.selectedOtuId = null
    row.fixedOtuId = null
    row.fixedOtuName = null
    row.ambiguous = false
    row.matched = false
    row.matchSource = null
    row.regexMatchString = ''
    row.userMatchString = ''
    row.selected = false
  })

  handleOptionsChange()
}

function scrollToRow(index) {
  const el = document.querySelector(`[data-row-index="${index}"]`)
  if (el) {
    el.scrollIntoView({ behavior: 'smooth', block: 'center' })
    el.classList.add('highlight-row')
    setTimeout(() => el.classList.remove('highlight-row'), 2500)
  }
}

function reset() {
  stage.value = 'input'
  rows.value = []
  csvData.value = null
  taxonNameFilter.value = TAXON_NAME_FILTER.All
  otuFilter.value = OTU_FILTER.All
  resetMatchOptions()
}
</script>

<style scoped>
/* Stretched (rather than the row's default flex-start) so this column's own
   box spans the full height of the results table next to it — giving
   .sticky-panel room to stick throughout the scroll instead of scrolling
   away as soon as this short column's natural content height passes. */
.left-column {
  align-self: stretch;
}

.sticky-panel {
  position: sticky;
  top: 0;
}

/* Matches .match-options-panel's own max-width (MatchOptionsPanel.vue) so this
   panel never grows wider than the options panel below it. */
.reset-panel {
  max-width: 400px;
}

/* Table cells paint their own (striped) background over the row's, so the
   animation has to run on each td — animating the tr itself is invisible. */
:deep(.highlight-row td) {
  animation: highlight-fade 2.5s ease-out;
}

@keyframes highlight-fade {
  0% {
    background-color: #ffffcc;
  }
  100% {
    background-color: transparent;
  }
}
</style>
