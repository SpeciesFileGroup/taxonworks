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
          :source-ids="exportedSourceIdSet"
          :not-in-project-count="notInProjectCount"
          @download="download"
          @download-unmatched="downloadUnmatched"
        />

        <VPagination
          v-if="pagination.totalPages > 1"
          class="margin-small-bottom"
          :pagination="pagination"
          @next-page="setPage"
        />

        <ResultTable
          :rows="pageItems"
          :evaluations="evaluations"
          :exported-source-ids="exportedSourceIds"
          :column-texts="columnTexts"
          v-model:filter="filter"
          @select-candidate="selectCandidate"
          @select-source="selectSource"
          @select-none="selectNone"
          @clear-selection="clearSelection"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { Parser } from '@json2csv/plainjs'
import { Source } from '@/routes/endpoints'
import { downloadTextFile } from '@/helpers/files'
import VSpinner from '@/components/ui/VSpinner.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VPagination from '@/components/pagination.vue'
import { usePagedList } from '@/composables/usePagedList.js'
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

// Parallel to rows.
const evaluations = computed(() =>
  rows.value.map((row) => evaluateRow(row, options.value))
)

function matchesFilter(row, filterValue) {
  const evaluation = evaluations.value[row.index]

  if (filterValue === ROW_FILTER.NOT_IN_PROJECT) {
    return evaluation.source?.in_project === false
  }
  return evaluation.status === filterValue
}

// Which rows a filter shows is captured when the filter or options change
// (or matching finishes), not recomputed live, so that selecting a Source
// doesn't make the row disappear from under the curator. Options apply
// first: an option change re-captures, and a selected row that no longer
// matches the filter leaves the view (its selection is kept).
const { filter, pageItems, pagination, setPage, refresh } = usePagedList(
  rows,
  {
    matches: matchesFilter,
    perPage: ROWS_PER_PAGE,
    frozen: true,
    refreshOn: [options]
  }
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
    fixedSource: null,
    noMatch: false // the user said none of the candidates is it
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

    await refreshSelectionsInProject()
  } catch {
    TW.workbench.alert.create('Error matching sources.', 'error')
  } finally {
    isProcessing.value = false
    refresh()
  }
}

// Whether a selected Source is in the project is recorded when it's
// selected; it may have been added (e.g. from the Source filter) since, and
// the project scope sets aside selections that aren't.
async function refreshSelectionsInProject() {
  const ids = [
    ...new Set(rows.value.map((row) => row.fixedSource?.id).filter(Boolean))
  ]
  if (!ids.length) return

  const inProject = await Source.filter({ source_id: ids, per: ids.length })
    .then(({ body }) =>
      new Map(body.map((source) => [source.id, source.source_in_project]))
    )
    .catch(() => null)
  if (!inProject) return

  rows.value.forEach((row) => {
    if (row.fixedSource && inProject.has(row.fixedSource.id)) {
      row.fixedSource.in_project = inProject.get(row.fixedSource.id)
    }
  })
}

function selectCandidate({ index, candidate }) {
  rows.value[index].noMatch = false
  rows.value[index].fixedSource = {
    ...candidate.source,
    in_project: candidate.in_project
  }
}

function selectNone({ index }) {
  rows.value[index].fixedSource = null
  rows.value[index].noMatch = true
}

function selectSource({ index, item }) {
  rows.value[index].noMatch = false
  rows.value[index].fixedSource = {
    id: item.id,
    object_label: item.label,
    in_project: item.is_in_project
  }
}

function clearSelection({ index }) {
  rows.value[index].fixedSource = null
  rows.value[index].noMatch = false
}

// The Source each row resolves to for export: ambiguous rows resolve to
// nothing until the curator picks one.
function exportedSource(row) {
  const evaluation = evaluations.value[row.index]
  return [STATUS.MATCHED, STATUS.SELECTED].includes(evaluation.status)
    ? evaluation.source
    : null
}

// Parallel to rows.
const exportedSourceIds = computed(() =>
  rows.value.map((row) => exportedSource(row)?.id ?? null)
)

// Copyable columns: one line per row, every row in input order (whatever
// the filter or page), so they paste back alongside the original sheet.
const columnTexts = computed(() => {
  const lines = (value) => rows.value.map(value).join('\n')

  return {
    status: lines((row) => evaluations.value[row.index].status),
    source: lines((row) =>
      plainText(exportedSource(row)?.object_label).replace(/\s+/g, ' ').trim()
    ),
    sourceId: lines((row) => exportedSource(row)?.id ?? '')
  }
})

// Matched and user selected Sources, each once.
const exportedSourceIdSet = computed(() => [
  ...new Set(exportedSourceIds.value.filter((id) => id != null))
])

const notInProjectCount = computed(() => {
  const ids = new Set()
  rows.value.forEach((row) => {
    const source = exportedSource(row)
    if (source?.in_project === false) ids.add(source.id)
  })
  return ids.size
})

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

function download() {
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
    .filter((row) =>
      [STATUS.UNMATCHED, STATUS.NO_MATCH].includes(
        evaluations.value[row.index].status
      )
    )
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
