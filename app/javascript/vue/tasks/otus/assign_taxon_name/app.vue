<template>
  <div class="task-container">
    <VSpinner
      v-if="isLoading"
      full-screen
    />

    <NavBar>
      <div class="flex-separate middle gap-medium full_width">
        <span class="subtle">
          {{ pagination.total ?? 0 }} OTUs without a taxon name
        </span>

        <ul
          v-if="pagination.totalPages > 1"
          class="context-menu"
        >
          <li>
            <VPagination
              :pagination="pagination"
              @next-page="({ page }) => loadPage(page)"
            />
          </li>
        </ul>
      </div>
    </NavBar>

    <div class="horizontal-left-content align-start gap-medium">
      <div class="left-column">
        <MatchOptionsPanel
          class="sticky-panel"
          v-model:scope-taxon-name="scopeTaxonName"
          v-model:strip-preset="stripPreset"
          v-model:levenshtein-distance="levenshteinDistance"
          v-model:use-author-year="useAuthorYear"
          v-model:modifiers="modifiers"
          :taxon-name-filter-url="taxonNameFilterUrl"
          @reset="handleReset"
          @update-options="() => loadPage(currentPage)"
        />
      </div>

      <div class="full_width">
        <StatusBar
          :rows="loadedRows"
          :scope-total="pagination.total ?? 0"
          :otu-filter-url="otuFilterUrl"
          :taxon-name-filter-url="taxonNameFilterUrl"
          @clear-set-rows="clearSetRows"
        />

        <ResultTable
          :rows="visibleRows"
          v-model:visibility="visibility"
          @update-row="updateRow"
          @update-match-string="updateMatchString"
          @toggle-all="toggleAll"
          @clear-predictions="clearPredictions"
          @refine="refine"
          @set="setTaxonName"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onBeforeMount, ref } from 'vue'
import { Otu } from '@/routes/endpoints'
import { getPagination } from '@/helpers'
import { PER, VISIBILITY, defaultModifiers } from './constants'
import { useScopeQueries } from './composables/useScopeQueries'
import applyRules from './utils/applyRules'
import MatchOptionsPanel from './components/MatchOptionsPanel.vue'
import NavBar from '@/components/layout/NavBar.vue'
import ResultTable from './components/ResultTable.vue'
import StatusBar from './components/StatusBar.vue'
import VPagination from '@/components/pagination.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

defineOptions({
  name: 'AssignTaxonNameToOtu'
})

const { otuQuery, taxonNameQuery, otuFilterUrl, taxonNameFilterUrl } =
  useScopeQueries()

const rows = ref([])
const pagination = ref({})
const isLoading = ref(false)
const visibility = ref(VISIBILITY.All)

// Match options
const scopeTaxonName = ref(null)
const stripPreset = ref(null)
const levenshteinDistance = ref(0)
const useAuthorYear = ref(false)
const modifiers = ref(defaultModifiers())

// Per-row state that must survive a refetch, keyed by OTU id.
const uiState = ref({})

// Rows the curator has removed from the view with "Clear set rows".
const clearedIds = ref([])

const currentPage = computed(() => pagination.value.paginationPage || 1)

// Everything still on the page. The status bar counts these, so its totals don't shift when
// the visibility filter is changed.
const loadedRows = computed(() =>
  rows.value.filter((row) => !clearedIds.value.includes(row.otuId))
)

const visibleRows = computed(() =>
  loadedRows.value.filter((row) => {
    if (visibility.value === VISIBILITY.Set) return row.set
    if (visibility.value === VISIBILITY.Unset) return !row.set
    return true
  })
)

const setRowIds = computed(() =>
  rows.value
    .filter((r) => r.set && !clearedIds.value.includes(r.otuId))
    .map((r) => r.otuId)
)

onBeforeMount(() => loadPage(1))

function requestParams(page, overrides) {
  return {
    page,
    per: PER,
    levenshtein_distance: levenshteinDistance.value,
    use_author_year: useAuthorYear.value ? 'true' : 'false',
    taxon_name_id: scopeTaxonName.value?.id,
    otu_query: otuQuery.value || undefined,
    taxon_name_query: taxonNameQuery.value || undefined,
    match_strings: overrides || undefined
  }
}

// The server matches on the OTU name unless told otherwise, so the first request for a page
// establishes which OTUs are on it; only then can the local rules produce match strings for
// them. When those differ from what the server used, the page is matched once more — at most
// two requests, and the second is skipped entirely when no rule is active.
async function loadPage(page = 1, overrides = null) {
  isLoading.value = true

  try {
    const response = await Otu.assignTaxonNameData(requestParams(page, overrides))

    rows.value = response.body.map(buildRow)
    pagination.value = getPagination(response)

    if (!overrides) {
      const computed = computeOverrides()

      if (Object.keys(computed).length) {
        return await loadPage(page, computed)
      }
    }
  } finally {
    isLoading.value = false
  }
}

function buildRow(record) {
  const otuId = record.otu.id
  const state = uiState.value[otuId] || {}

  return {
    otuId,
    otuName: record.otu.name,
    otuGlobalId: record.otu.global_id,
    matchString: record.match_string,
    candidates: record.candidates,
    ambiguous: record.ambiguous,
    // A prior pick survives a refetch, otherwise the best ranked candidate is preselected.
    taxonNameId: state.taxonNameId ?? record.taxon_name_id,
    selected: state.selected ?? false,
    set: state.set ?? false,
    error: state.error ?? null
  }
}

// Match strings that differ from the OTU name the server matched on.
function computeOverrides() {
  const overrides = {}

  rows.value.forEach((row) => {
    const manual = uiState.value[row.otuId]?.matchString
    const value =
      manual ?? applyRules(row.otuName, stripPreset.value, modifiers.value)

    if (value && value !== row.otuName) {
      overrides[row.otuId] = value
    }
  })

  return overrides
}

function rememberState(row, field, value) {
  uiState.value[row.otuId] = {
    ...(uiState.value[row.otuId] || {}),
    [field]: value
  }
}

function updateRow(row, field, value) {
  rememberState(row, field, value)
  row[field] = value
}

function updateMatchString(row, value) {
  rememberState(row, 'matchString', value)
  loadPage(currentPage.value, {
    ...computeOverrides(),
    [row.otuId]: value
  })
}

function toggleAll(checked) {
  visibleRows.value.forEach((row) => updateRow(row, 'selected', checked))
}

function clearPredictions() {
  visibleRows.value.forEach((row) => updateRow(row, 'taxonNameId', null))
}

function refine(row, item) {
  const taxonNameId = item.response_values?.taxon_name_id

  if (!taxonNameId) return

  // The refined name need not be among the predictions, so it is added as a candidate to
  // keep the radio group and the Set button consistent.
  if (!row.candidates.some((c) => c.id === taxonNameId)) {
    row.candidates = [
      ...row.candidates,
      {
        id: taxonNameId,
        cached_html: item.label_html || item.label,
        cached_author_year: null
      }
    ]
  }

  updateRow(row, 'taxonNameId', taxonNameId)
}

async function setTaxonName(row) {
  updateRow(row, 'error', null)

  try {
    await Otu.update(row.otuId, { otu: { taxon_name_id: row.taxonNameId } })
    updateRow(row, 'set', true)
  } catch {
    updateRow(row, 'error', 'Failed to set')
  }
}

function clearSetRows() {
  clearedIds.value = [...clearedIds.value, ...setRowIds.value]
}

function handleReset() {
  scopeTaxonName.value = null
  stripPreset.value = null
  levenshteinDistance.value = 0
  useAuthorYear.value = false
  modifiers.value = defaultModifiers()
  uiState.value = {}
  clearedIds.value = []
  loadPage(1)
}
</script>

<style scoped>
.left-column {
  align-self: stretch;
}

.sticky-panel {
  position: sticky;
  top: 0;
}
</style>
