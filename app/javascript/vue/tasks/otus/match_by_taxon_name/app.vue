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
              :rows="rows"
              :csv-data="csvData"
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
import { ref, nextTick, onMounted } from 'vue'
import { TaxonName, Otu } from '@/routes/endpoints'
import VSpinner from '@/components/ui/VSpinner.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import InputPanel from './components/InputPanel.vue'
import ResultTable from './components/ResultTable.vue'
import SummaryBar from './components/SummaryBar.vue'
import MatchOptionsPanel from './components/MatchOptionsPanel.vue'
import { MAX_ROWS, defaultModifiers } from './constants.js'
import effectiveName from './utils/effectiveName.js'
import sortOtus from './utils/sortOtus.js'

defineOptions({
  name: 'MatchOtuByTaxonName'
})

const stage = ref('input') // 'input' or 'results'
const isProcessing = ref(false)
const rows = ref([])
const csvData = ref(null)

const scopeTaxonName = ref()
const levenshteinDistance = ref(0)
const tryWithoutSubgenus = ref(false)
const resolveSynonyms = ref(false)

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

const modifiers = ref(defaultModifiers())

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
    applyMatchResult(row, {
      taxonName: value,
      taxonNameId: value?.id || null,
      otus: [],
      selectedOtuId: null,
      ambiguous: false,
      matched: !!value
    })

    if (value) {
      loadOtusForTaxonName(value.id, row)
    }

    syncDuplicateRows(row)
  } else if (field === 'userMatchString') {
    row.userMatchString = value
  } else if (field === 'selected') {
    row.selected = value
  } else if (field === 'selectedOtuId') {
    row.selectedOtuId = value
    syncDuplicateRows(row)
  }
}

async function loadOtusForTaxonName(taxonNameId, row) {
  try {
    const { body } = await TaxonName.otus(taxonNameId)
    row.otus = sortOtus(body.map((o) => ({
      id: o.id,
      name: o.name,
      taxon_name_id: o.taxon_name_id,
      object_label: o.object_label
    })))
    if (row.otus.length) {
      row.selectedOtuId = row.otus[0].id
    }
    syncDuplicateRows(row)
  } catch (e) {
    console.error('Failed to load OTUs:', e)
  }
}

async function handleCreateOtu({ index }) {
  const row = rows.value[index]
  if (!row?.taxonNameId) return

  try {
    const { body } = await Otu.create({
      otu: { taxon_name_id: row.taxonNameId }
    })
    const newOtu = {
      id: body.id,
      name: body.name,
      taxon_name_id: body.taxon_name_id,
      object_label: body.object_label
    }

    row.otus.push(newOtu)
    row.selectedOtuId = newOtu.id

    syncDuplicateRows(row)
    TW.workbench.alert.create('OTU created successfully.', 'notice')
  } catch (e) {
    TW.workbench.alert.create('Failed to create OTU.', 'error')
    console.error(e)
  }
}

function applyMatchResult(row, source) {
  row.taxonName = source.taxonName
  row.taxonNameId = source.taxonNameId
  row.otus = source.otus
  row.selectedOtuId = source.selectedOtuId
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
    setTimeout(() => el.classList.remove('highlight-row'), 2000)
  }
}

function reset() {
  stage.value = 'input'
  rows.value = []
  csvData.value = null
  resetMatchOptions()
}
</script>

<style scoped>
:deep(.highlight-row) {
  animation: highlight-fade 2s ease-out;
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
