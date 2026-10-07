<template>
  <div class="margin-medium-top">
    <VSpinner
      v-if="isProcessing"
      full-screen
      :legend="progressLegend"
    />

    <InputPanel
      v-if="stage === 'input'"
      @submit="handleSubmit"
    />

    <div
      v-else
      class="flex-row align-start gap-medium"
    >
      <div class="flex-col gap-medium left-column">
        <div class="panel content">
          <VBtn
            circle
            color="primary"
            title="Start over with new citations"
            @click="reset"
          >
            <VIcon
              x-small
              name="reset"
            />
          </VBtn>
        </div>

        <MatchOptionsPanel
          class="sticky-panel"
          v-model:options="options"
          @reset="resetOptions"
          @refetch="fetchCandidates"
        />
      </div>

      <div class="full_width">
        <SummaryBar
          :evaluations="evaluations"
          :not-in-project-count="sourcesToAddToProject().length"
          v-model:add-to-project="addToProject"
          @download="download"
          @download-unmatched="downloadUnmatched"
        />

        <div
          v-if="pageCount > 1"
          class="horizontal-left-content middle gap-small margin-small-bottom"
        >
          <VBtn
            color="primary"
            medium
            :disabled="page === 0"
            @click="page--"
          >
            Previous
          </VBtn>
          <span>
            Page {{ page + 1 }} of {{ pageCount }} ({{ visibleRows.length }}
            rows)
          </span>
          <VBtn
            color="primary"
            medium
            :disabled="page >= pageCount - 1"
            @click="page++"
          >
            Next
          </VBtn>
        </div>

        <ResultTable
          :rows="pageRows"
          :evaluations="evaluations"
          v-model:filter="filter"
          @select-candidate="selectCandidate"
          @select-source="selectSource"
          @clear-selection="clearSelection"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { Parser } from '@json2csv/plainjs'
import { Source, ProjectSource } from '@/routes/endpoints'
import { downloadTextFile } from '@/helpers/files'
import VSpinner from '@/components/ui/VSpinner.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import InputPanel from './components/InputPanel.vue'
import MatchOptionsPanel from './components/MatchOptionsPanel.vue'
import SummaryBar from './components/SummaryBar.vue'
import ResultTable from './components/ResultTable.vue'
import { evaluateRow } from './utils/evaluate.js'
import {
  CHUNK_SIZE,
  FIELD,
  MAX_YEAR_TOLERANCE,
  ROW_FILTER,
  ROWS_PER_PAGE,
  STATUS,
  defaultOptions
} from './constants.js'

defineOptions({
  name: 'MatchSources'
})

const stage = ref('input') // 'input' or 'results'
const isProcessing = ref(false)
const progressLegend = ref('')
const rows = ref([])
const headers = ref(null) // CSV headers, null for verbatim lines
const options = ref(defaultOptions())
const filter = ref(ROW_FILTER.ALL)
const page = ref(0)
const addToProject = ref(false)

// Parallel to rows.
const evaluations = computed(() =>
  rows.value.map((row) => evaluateRow(row, options.value))
)

function matchesFilter(row) {
  const evaluation = evaluations.value[row.index]

  if (filter.value === ROW_FILTER.ALL) return true
  if (filter.value === ROW_FILTER.NOT_IN_PROJECT) {
    return evaluation.source?.in_project === false
  }
  return evaluation.status === filter.value
}

// Which rows a filter shows is captured when the filter or options change,
// not recomputed live, so that selecting a Source doesn't make the row
// disappear from under the curator.
const visibleRowIndices = ref(null) // null: no filter, every row

function snapshotVisibleRows() {
  page.value = 0

  if (filter.value === ROW_FILTER.ALL) {
    visibleRowIndices.value = null
    return
  }

  visibleRowIndices.value = new Set(
    rows.value.filter(matchesFilter).map((row) => row.index)
  )
}

watch([filter, options], snapshotVisibleRows)

const visibleRows = computed(() =>
  visibleRowIndices.value === null
    ? rows.value
    : rows.value.filter((row) => visibleRowIndices.value.has(row.index))
)

const pageCount = computed(() =>
  Math.max(1, Math.ceil(visibleRows.value.length / ROWS_PER_PAGE))
)

const pageRows = computed(() =>
  visibleRows.value.slice(
    page.value * ROWS_PER_PAGE,
    (page.value + 1) * ROWS_PER_PAGE
  )
)

async function handleSubmit({ rows: submitted, headers: submittedHeaders }) {
  headers.value = submittedHeaders
  rows.value = submitted.map(({ input, csvRow }, index) => ({
    index,
    input,
    csvRow,
    isEmpty: !Object.values(input).some((v) => v?.trim()),
    parsed: null,
    candidates: [],
    fixedSource: null
  }))

  stage.value = 'results'
  await fetchCandidates()
}

// Identical rows are matched once.
function inputKey(input) {
  return JSON.stringify(Object.values(FIELD).map((field) => input[field] || ''))
}

async function fetchCandidates() {
  const rowsByKey = new Map()

  rows.value.forEach((row) => {
    if (row.isEmpty) return
    const key = inputKey(row.input)
    if (!rowsByKey.has(key)) rowsByKey.set(key, [])
    rowsByKey.get(key).push(row)
  })

  const keys = [...rowsByKey.keys()]

  isProcessing.value = true

  try {
    for (let start = 0; start < keys.length; start += CHUNK_SIZE) {
      progressLegend.value =
        `Matching ${Math.min(start + CHUNK_SIZE, keys.length)} of ` +
        `${keys.length} unique rows...`

      const chunk = keys.slice(start, start + CHUNK_SIZE)
      const { body } = await Source.match({
        rows: chunk.map((key) => rowsByKey.get(key)[0].input),
        limit_to_project: options.value.limitToProject ? 'true' : 'false',
        year_window: MAX_YEAR_TOLERANCE
      })

      body.forEach((result) => {
        rowsByKey.get(chunk[result.index]).forEach((row) => {
          row.parsed = result.parsed
          row.candidates = result.candidates
        })
      })
    }
  } catch {
    TW.workbench.alert.create('Error matching sources.', 'error')
  } finally {
    isProcessing.value = false
    snapshotVisibleRows()
  }
}

function selectCandidate({ index, candidate }) {
  rows.value[index].fixedSource = {
    ...candidate.source,
    in_project: candidate.in_project
  }
}

function selectSource({ index, item }) {
  rows.value[index].fixedSource = {
    id: item.id,
    object_label: item.label,
    in_project: item.is_in_project
  }
}

function clearSelection({ index }) {
  rows.value[index].fixedSource = null
}

// The Source each row resolves to for export: ambiguous rows resolve to
// nothing until the curator picks one.
function exportedSource(row) {
  const evaluation = evaluations.value[row.index]
  return [STATUS.MATCHED, STATUS.SELECTED].includes(evaluation.status)
    ? evaluation.source
    : null
}

function sourcesToAddToProject() {
  const ids = new Set()
  rows.value.forEach((row) => {
    const source = exportedSource(row)
    if (source && source.in_project === false) ids.add(source.id)
  })
  return [...ids]
}

async function addSourcesToProject() {
  const ids = sourcesToAddToProject()
  if (!ids.length) return true

  try {
    await ProjectSource.batchSyncToProject({
      source_query: { source_id: ids },
      operation: 'add'
    })
  } catch {
    TW.workbench.alert.create('Error adding Sources to the project.', 'error')
    return false
  }

  const added = new Set(ids)
  rows.value.forEach((row) => {
    row.candidates.forEach((c) => {
      if (added.has(c.source.id)) c.in_project = true
    })
    if (added.has(row.fixedSource?.id)) row.fixedSource.in_project = true
  })

  TW.workbench.alert.create(
    `${ids.length} Source(s) added to the project.`,
    'notice'
  )
  return true
}

function plainText(html) {
  return new DOMParser().parseFromString(html || '', 'text/html').body
    .textContent
}

function originalColumns(row) {
  return headers.value
    ? { ...row.csvRow }
    : { [FIELD.VERBATIM]: row.input[FIELD.VERBATIM] || '' }
}

function toCsv(records) {
  return new Parser().parse(records)
}

async function download() {
  if (addToProject.value && !(await addSourcesToProject())) return

  const records = rows.value.map((row) => {
    const source = exportedSource(row)
    return {
      ...originalColumns(row),
      source_id: source?.id ?? '',
      match_status: evaluations.value[row.index].status,
      source: plainText(source?.object_label)
    }
  })

  downloadTextFile(toCsv(records), 'text/csv', 'matched_sources.csv')
}

function downloadUnmatched() {
  const records = rows.value
    .filter((row) => evaluations.value[row.index].status === STATUS.UNMATCHED)
    .map(originalColumns)

  downloadTextFile(toCsv(records), 'text/csv', 'unmatched_sources.csv')
}

function resetOptions() {
  const refetch = options.value.limitToProject !== defaultOptions().limitToProject
  options.value = defaultOptions()
  if (refetch) fetchCandidates()
}

function reset() {
  stage.value = 'input'
  rows.value = []
  headers.value = null
  filter.value = ROW_FILTER.ALL
  options.value = defaultOptions()
  addToProject.value = false
}
</script>

<style scoped>
/* Stretched so .sticky-panel has the table's full height to stick within. */
.left-column {
  align-self: stretch;
}

.sticky-panel {
  position: sticky;
  top: 0;
}
</style>
