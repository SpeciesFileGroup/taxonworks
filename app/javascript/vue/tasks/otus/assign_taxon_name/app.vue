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
          :style="{ top: `${stickyTop}px`, maxHeight: `calc(100vh - ${stickyTop}px)` }"
          v-model:scope-taxon-name="scopeTaxonName"
          v-model:strip-preset="stripPreset"
          v-model:levenshtein-distance="levenshteinDistance"
          v-model:use-author-year="useAuthorYear"
          v-model:modifiers="modifiers"
          :taxon-name-filter-url="taxonNameFilterUrl"
          :scoped-count="scopedRows.length"
          @reset="handleReset"
          @update-options="handleOptionsChange"
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
          v-model:prediction="prediction"
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
import { computed, onBeforeMount, onMounted, ref, watch } from 'vue'
import { Otu } from '@/routes/endpoints'
import { getPagination } from '@/helpers'
import { useScroll } from '@/composables'
import { PER, PREDICTION, VISIBILITY, defaultModifiers } from './constants'
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
const prediction = ref(PREDICTION.All)

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

// Everything still on the page. The status bar counts these, so its totals don't shift when
// the visibility filter is changed.
const loadedRows = computed(() =>
  rows.value.filter((row) => !clearedIds.value.includes(row.otuId))
)

// Filters hide rather than reorder, so the surviving rows keep the server's name order and
// the ones of interest gather at the top.
const visibleRows = computed(() =>
  loadedRows.value.filter((row) => {
    if (visibility.value === VISIBILITY.Set && !row.set) return false
    if (visibility.value === VISIBILITY.Unset && row.set) return false

    const predicted = row.candidates.length > 0

    if (prediction.value === PREDICTION.Predicted && !predicted) return false
    if (prediction.value === PREDICTION.Unknown && predicted) return false

    return true
  })
)

// Checked rows are the sole target of the left-column match options.
const scopedRows = computed(() => loadedRows.value.filter((r) => r.selected))

const setRowIds = computed(() =>
  rows.value
    .filter((r) => r.set && !clearedIds.value.includes(r.otuId))
    .map((r) => r.otuId)
)

onBeforeMount(() => loadPage(1))

// Sticking to the viewport top puts the panel under whatever is fixed up there: the NavBar
// above, which fixes itself once the page scrolls, or the app header when the curator has
// locked it. Neither is fixed at first, and the NavBar only takes its class on scroll, so the
// clearance is re-read on every scroll rather than measured once.
const scroll = useScroll(window)
const stickyTop = ref(0)

function updateStickyTop() {
  const fixedElement = [
    document.querySelector('.navbar-fixed-top'),
    document.querySelector('#header-wrapper')
  ].find((element) => element && getComputedStyle(element).position === 'fixed')

  stickyTop.value = fixedElement?.getBoundingClientRect().bottom ?? 0
}

onMounted(updateStickyTop)
watch(scroll.y, updateStickyTop)

// How to match, without saying what to match — shared by the page request and the
// single-row refresh so both see the same options.
function matchOptions() {
  return {
    levenshtein_distance: levenshteinDistance.value,
    use_author_year: useAuthorYear.value ? 'true' : 'false',
    taxon_name_id: scopeTaxonName.value?.id,
    taxon_name_query: taxonNameQuery.value || undefined
  }
}

function requestParams(page, overrides) {
  return {
    ...matchOptions(),
    page,
    per: PER,
    otu_query: otuQuery.value || undefined,
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

// Checked rows scope the left-column facets; with nothing checked they apply to every row.
// Match strings that differ from the OTU name the server matched on. A string the curator
// typed always counts; the left-column rules reach checked rows only.
function computeOverrides() {
  const overrides = {}
  const scoped = new Set(scopedRows.value.map((r) => r.otuId))

  rows.value.forEach((row) => {
    const manual = uiState.value[row.otuId]?.matchString
    const value =
      manual ??
      (scoped.has(row.otuId)
        ? applyRules(row.otuName, stripPreset.value, modifiers.value)
        : row.otuName)

    if (value && value !== row.otuName) {
      overrides[row.otuId] = value
    }
  })

  return overrides
}

// Re-match the given rows and patch them in place, leaving every other row's prediction
// alone. Set rows are finished, so they are never re-matched.
async function refreshRows(target, overrides = {}) {
  const rowsToMatch = target.filter((row) => !row.set)

  if (!rowsToMatch.length) return

  const matchStrings = {}

  rowsToMatch.forEach((row) => {
    const value =
      overrides[row.otuId] ??
      uiState.value[row.otuId]?.matchString ??
      applyRules(row.otuName, stripPreset.value, modifiers.value)

    if (value) matchStrings[row.otuId] = value
  })

  const response = await Otu.assignTaxonNameData({
    ...matchOptions(),
    otu_query: { otu_id: rowsToMatch.map((r) => r.otuId) },
    per: rowsToMatch.length,
    match_strings: matchStrings
  })

  response.body.forEach((record) => {
    const row = rows.value.find((r) => r.otuId === record.otu.id)

    if (!row) return

    row.matchString = record.match_string
    row.candidates = record.candidates
    row.ambiguous = record.ambiguous

    // The string these were matched on changed, so an earlier pick no longer stands.
    row.taxonNameId = record.taxon_name_id
    rememberState(row, 'taxonNameId', record.taxon_name_id)
  })
}

// Match options act on the checked rows and nothing else, so with none checked there is
// nothing to re-match — moving the slider must not disturb the page.
function handleOptionsChange() {
  return refreshRows(scopedRows.value)
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

// Editing one row's match string re-matches that row alone. Reloading the page here would
// re-apply the left-column rules to every row and replace all their predictions, discarding
// work elsewhere on the page.
function updateMatchString(row, value) {
  rememberState(row, 'matchString', value)
  return refreshRows([row], { [row.otuId]: value })
}

function toggleAll(checked) {
  visibleRows.value.forEach((row) => updateRow(row, 'selected', checked))
}

function clearPredictions() {
  visibleRows.value.forEach((row) => {
    if (!row.set) updateRow(row, 'taxonNameId', null)
  })
}

function refine(row, item) {
  const taxonNameId = item.response_values?.taxon_name_id

  // A set row is final here — corrections are made against the OTU itself.
  if (!taxonNameId || row.set) return

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

  // Choosing a name in Refine is the decision itself — picking an existing one, or creating
  // one for this OTU. Nothing is left to confirm, so write it.
  return setTaxonName(row)
}

async function setTaxonName(row) {
  if (row.set) return

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
  visibility.value = VISIBILITY.All
  prediction.value = PREDICTION.All
  uiState.value = {}
  clearedIds.value = []
  loadPage(1)
}
</script>

<style scoped>
.left-column {
  align-self: stretch;
}

/* `top` and `max-height` come from the measured clearance below the fixed bars; the panel
   scrolls on its own once it is taller than what is left of the viewport. */
.sticky-panel {
  position: sticky;
  overflow-y: auto;
}
</style>
