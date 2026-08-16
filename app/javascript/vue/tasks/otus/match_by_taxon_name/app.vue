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
          <div class="panel content">
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
            />

            <ResultTable
              :rows="visibleRows"
              :csv-data="csvData"
              v-model:taxon-name-filter="taxonNameFilter"
              @update-row="handleRowUpdate"
              @create-otu="handleCreateOtu"
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
import { computed, ref, onMounted } from 'vue'
import { TaxonName, Otu } from '@/routes/endpoints'
import VSpinner from '@/components/ui/VSpinner.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import InputPanel from './components/InputPanel.vue'
import ResultTable from './components/ResultTable.vue'
import SummaryBar from './components/SummaryBar.vue'
import MatchOptionsPanel from './components/MatchOptionsPanel.vue'
import { MAX_ROWS, TAXON_NAME_FILTER, defaultModifiers } from './constants.js'
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

const visibleRows = computed(() =>
  rows.value.filter((row) => {
    if (taxonNameFilter.value === TAXON_NAME_FILTER.Ambiguous) return row.matched && row.ambiguous
    if (taxonNameFilter.value === TAXON_NAME_FILTER.Unmatched) return !row.matched
    return true
  })
)

const scopeTaxonName = ref()
const levenshteinDistance = ref(0)
const tryWithoutSubgenus = ref(false)
const resolveSynonyms = ref(false)

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
      ambiguous: false,
      matched: false,
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
  return checked.length ? checked : rows.value.filter((r) => !r.isEmpty)
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
      try_without_subgenus: tryWithoutSubgenus.value ? 'true' : 'false'
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
          matched: result.matched
        })
      })
    })
  } catch (e) {
    TW.workbench.alert.create(
      'Error matching names. See console for details.',
      'error'
    )
    console.error(e)
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
      // The autocomplete result doesn't include cached_html (only label/label_html,
      // meant for the dropdown itself), so re-fetch the full record for display.
      refreshTaxonNameSelection(value.id, row)
    } else {
      applyMatchResult(row, {
        taxonName: null,
        taxonNameId: null,
        otus: [],
        selectedOtuId: null,
        ambiguous: false,
        matched: false
      })
      syncDuplicateRows(row)
    }
  } else if (field === 'userMatchString') {
    row.userMatchString = value
  } else if (field === 'selected') {
    row.selected = value
  } else if (field === 'selectedOtuId') {
    // A radio click explicitly fixes the OTU: it survives subsequent
    // re-matches (e.g. toggling match options) until reset.
    row.fixedOtuId = value
    row.selectedOtuId = value
    syncDuplicateRows(row)
  } else if (field === 'fixedOtuId') {
    row.fixedOtuId = value
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
      matched: true
    })

    syncDuplicateRows(row)
  } catch (e) {
    TW.workbench.alert.create(
      'Error loading TaxonName/OTU details.',
      'error'
    )
    console.error(e)
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
    row.selectedOtuId = newOtu.id

    syncDuplicateRows(row)
    TW.workbench.alert.create('OTU created successfully.', 'notice')
  } catch (e) {
    TW.workbench.alert.create('Failed to create OTU.', 'error')
    console.error(e)
  }
}

// A row.fixedOtuId (set by an explicit radio click) survives a re-applied
// otus list: reselect it if still present, otherwise leave nothing selected
// (rather than falling back to source.selectedOtuId) until it reappears.
function resolveSelectedOtuId(row, otus, defaultSelectedOtuId) {
  if (row.fixedOtuId != null) {
    return otus.some((otu) => otu.id === row.fixedOtuId) ? row.fixedOtuId : null
  }
  return defaultSelectedOtuId
}

function applyMatchResult(row, source) {
  row.taxonName = source.taxonName
  row.taxonNameId = source.taxonNameId
  row.otus = source.otus
  row.selectedOtuId = resolveSelectedOtuId(row, source.otus, source.selectedOtuId)
  row.ambiguous = source.ambiguous
  row.matched = source.matched
}

function syncDuplicateRows(sourceRow) {
  const sourceName = effectiveName(sourceRow)

  rows.value.forEach((row) => {
    if (row.index === sourceRow.index) return

    if (effectiveName(row) === sourceName) {
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
  modifiers.value = defaultModifiers()
}

function clearAllMatches() {
  resetMatchOptions()

  rows.value.forEach((row) => {
    row.taxonName = null
    row.taxonNameId = null
    row.otus = []
    row.selectedOtuId = null
    row.fixedOtuId = null
    row.ambiguous = false
    row.matched = false
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
