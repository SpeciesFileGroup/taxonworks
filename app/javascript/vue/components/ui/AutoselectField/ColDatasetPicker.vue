<!-- ColDatasetPicker.vue
  Model-specific options component for autoselects that include a catalogue_of_life level.
  Passed as the optionsComponent prop to PreferencesModal.

  Renders a search box for CoL datasets. The user selects a dataset; the chosen id is
  stored in levelOptions['catalogue_of_life'].dataset_id and carried to the server on
  every catalogue_of_life search.

  Props (from PreferencesModal):
    levels      Array of level metadata — used to detect whether catalogue_of_life is present
    modelValue  { [level_key]: { ...options } }  — the current level-keyed options map

  Emits:
    update:modelValue  — updated options map after dataset selection
-->
<template>
  <div
    v-if="hasColLevel"
    class="col-dataset-picker"
  >
    <label class="col-dataset-picker__label">Catalogue of Life dataset</label>

    <!-- Current selection -->
    <div
      v-if="selectedDataset"
      class="col-dataset-picker__selected"
    >
      <span class="col-dataset-picker__selected-title">{{ selectedDataset.title }}</span>
      <span
        v-if="selectedDataset.alias"
        class="col-dataset-picker__selected-alias"
      >{{ selectedDataset.alias }}</span>
      <button
        class="col-dataset-picker__clear"
        title="Clear — use default dataset"
        @click="clearDataset"
      >&#x2715;</button>
    </div>
    <p
      v-else
      class="col-dataset-picker__default-note"
    >
      Using default dataset (Catalogue of Life).
    </p>

    <!-- Search -->
    <div class="col-dataset-picker__search-row">
      <input
        v-model="query"
        type="text"
        class="col-dataset-picker__input normal-input"
        placeholder="Search datasets by name…"
        autocomplete="off"
        @input="onQueryInput"
      />
      <span
        v-if="isSearching"
        class="col-dataset-picker__searching"
      >…</span>
    </div>

    <!-- Results -->
    <ul
      v-if="results.length > 0"
      class="col-dataset-picker__results"
    >
      <li
        v-for="dataset in results"
        :key="dataset.id"
        class="col-dataset-picker__result"
        @click="selectDataset(dataset)"
      >
        <span class="col-dataset-picker__result-title">{{ dataset.title }}</span>
        <span
          v-if="dataset.alias"
          class="col-dataset-picker__result-alias"
        >{{ dataset.alias }}</span>
        <span class="col-dataset-picker__result-id">{{ dataset.id }}</span>
      </li>
    </ul>
    <p
      v-else-if="searched && !isSearching"
      class="col-dataset-picker__none"
    >
      No datasets found.
    </p>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import AjaxCall from '@/helpers/ajaxCall'

const props = defineProps({
  levels: { type: Array, required: true },
  modelValue: { type: Object, default: () => ({}) }
})

const emit = defineEmits(['update:modelValue'])

const LEVEL_KEY = 'catalogue_of_life'

// ── Computed ───────────────────────────────────────────────────────────────────
const hasColLevel = computed(() =>
  props.levels.some((l) => String(l.key) === LEVEL_KEY)
)

const currentDatasetId = computed(
  () => props.modelValue?.[LEVEL_KEY]?.dataset_id || null
)

// ── Refs ───────────────────────────────────────────────────────────────────────
const query = ref('')
const results = ref([])
const isSearching = ref(false)
const searched = ref(false)
let searchTimer = null

// The selected dataset object (id + title + alias), reconstructed from saved id
const selectedDataset = ref(
  currentDatasetId.value ? { id: currentDatasetId.value, title: currentDatasetId.value, alias: null } : null
)

// ── Search ─────────────────────────────────────────────────────────────────────
function onQueryInput() {
  clearTimeout(searchTimer)
  if (!query.value.trim()) {
    results.value = []
    searched.value = false
    return
  }
  searchTimer = setTimeout(() => searchDatasets(query.value.trim()), 400)
}

async function searchDatasets(q) {
  isSearching.value = true
  try {
    const { body } = await AjaxCall('get', '/taxon_names/autoselect_col_datasets', { params: { q } })
    results.value = Array.isArray(body) ? body : []
    searched.value = true
  } catch {
    results.value = []
  } finally {
    isSearching.value = false
  }
}

// ── Selection ──────────────────────────────────────────────────────────────────
function selectDataset(dataset) {
  selectedDataset.value = dataset
  results.value = []
  query.value = ''
  searched.value = false
  emitOptions(dataset.id)
}

function clearDataset() {
  selectedDataset.value = null
  emitOptions(null)
}

function emitOptions(datasetId) {
  const updated = { ...props.modelValue }
  updated[LEVEL_KEY] = { ...(updated[LEVEL_KEY] || {}), dataset_id: datasetId }
  emit('update:modelValue', updated)
}
</script>

<style scoped>
.col-dataset-picker {
  display: flex;
  flex-direction: column;
  gap: 6px;
  font-size: 12px;
}

.col-dataset-picker__label {
  font-size: 11px;
  font-weight: 600;
  color: var(--text-color-muted, #666);
}

.col-dataset-picker__selected {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 3px 8px;
  background: var(--input-bg-color, #f9f9f9);
  border: 1px solid var(--border-color, #ccc);
  border-radius: 3px;
}

.col-dataset-picker__selected-alias {
  font-size: 10px;
  color: var(--text-color-muted, #888);
}

.col-dataset-picker__clear {
  background: none;
  border: none;
  cursor: pointer;
  font-size: 11px;
  color: var(--text-color-muted, #888);
  margin-left: auto;
  padding: 0 2px;
}

.col-dataset-picker__clear:hover {
  color: var(--color-destroy, #c00);
}

.col-dataset-picker__default-note {
  font-size: 11px;
  color: var(--text-color-muted, #888);
  margin: 0;
}

.col-dataset-picker__search-row {
  display: flex;
  align-items: center;
  gap: 6px;
}

.col-dataset-picker__input {
  flex: 1;
  box-sizing: border-box;
}

.col-dataset-picker__searching {
  font-size: 11px;
  color: var(--text-color-muted, #888);
}

.col-dataset-picker__results {
  list-style: none;
  margin: 0;
  padding: 0;
  border: 1px solid var(--border-color, #ccc);
  border-radius: 3px;
  max-height: 180px;
  overflow-y: auto;
  background: var(--panel-bg-color, #fff);
}

.col-dataset-picker__result {
  display: flex;
  align-items: baseline;
  gap: 6px;
  padding: 5px 8px;
  border-top: 1px solid var(--border-color, #eee);
  cursor: pointer;
}

.col-dataset-picker__result:first-child {
  border-top: none;
}

.col-dataset-picker__result:hover {
  background: var(--border-color, #f0f0f0);
}

.col-dataset-picker__result-alias,
.col-dataset-picker__result-id {
  font-size: 10px;
  color: var(--text-color-muted, #888);
  white-space: nowrap;
}

.col-dataset-picker__none {
  font-size: 11px;
  color: var(--text-color-muted, #888);
  margin: 2px 0 0;
}
</style>
