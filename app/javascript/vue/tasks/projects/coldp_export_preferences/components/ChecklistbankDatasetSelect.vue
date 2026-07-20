<template>
  <div class="position-relative margin-small-top">
    <input
      type="text"
      v-model="searchQuery"
      placeholder="Search ChecklistBank datasets..."
      :class="['full_width', { 'vue-autocomplete-input-search': !isSearching }]"
      @input="onInput"
      @keydown.delete="onBackspace"
    />
    <CatalogueOfLifeSpinner
      v-if="isSearching"
      class="clb-spinner"
    />
    <ul
      v-if="results.length > 0 && isOpen"
      class="vue-autocomplete-list"
    >
      <li
        v-for="dataset in results"
        :key="dataset.key"
        class="d-flex flex-column gap-xsmall cursor-pointer padding-xsmall"
        @click="selectDataset(dataset)"
      >
        <div class="d-flex align-items-center">
          <span class="font-bold line-nowrap">#{{ dataset.key }}</span>
          <span
            v-if="dataset.alias"
            class="line-nowrap"
          >
            ({{ dataset.alias }})</span
          >
        </div>
        <span class="ellipsis">{{ dataset.title }}</span>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getCurrentProjectId } from '@/helpers/project.js'
import { ColdpExportPreference } from '@/routes/endpoints'
import CatalogueOfLifeSpinner from '@/components/ui/AutoselectField/CatalogueOfLifeSpinner.vue'

const projectId = Number(getCurrentProjectId())

const props = defineProps({
  datasetId: {
    type: [Number, String],
    default: null
  }
})

const emit = defineEmits(['update:datasetId'])

const searchQuery = ref('')
const results = ref([])
const isOpen = ref(false)
const isSearching = ref(false)
let searchTimeout = null

onMounted(() => {
  if (props.datasetId) {
    fetchDatasetLabel(props.datasetId)
  }
})

function displayLabel(dataset) {
  return [dataset.key || dataset, dataset.alias, dataset.title]
    .filter(Boolean)
    .join(' - ')
}

function onInput() {
  if (props.datasetId) {
    emit('update:datasetId', null)
  }

  clearTimeout(searchTimeout)
  const query = searchQuery.value.trim()

  if (query.length < 2) {
    results.value = []
    isOpen.value = false
    isSearching.value = false
    return
  }

  isSearching.value = true

  searchTimeout = setTimeout(async () => {
    try {
      const { body } = await ColdpExportPreference.searchDatasets(projectId, {
        q: query
      })
      results.value = body || []
      isOpen.value = true
    } catch {
      results.value = []
    } finally {
      isSearching.value = false
    }
  }, 300)
}

function onBackspace() {
  if (searchQuery.value === '' && props.datasetId) {
    emit('update:datasetId', null)
  }
}

function selectDataset(dataset) {
  searchQuery.value = displayLabel(dataset)
  results.value = []
  isOpen.value = false
  emit('update:datasetId', dataset.key)
}

function fetchDatasetLabel(datasetId) {
  isSearching.value = true
  ColdpExportPreference.searchDatasets(projectId, { q: String(datasetId) })
    .then(({ body }) => {
      const match = (body || []).find((d) => d.key === datasetId)
      searchQuery.value = match ? displayLabel(match) : String(datasetId)
    })
    .catch(() => {
      searchQuery.value = String(datasetId)
    })
    .finally(() => {
      isSearching.value = false
    })
}
</script>

<style scoped>
.clb-spinner {
  position: absolute;
  top: 50%;
  right: 8px;
  transform: translateY(-50%);
  pointer-events: none;
}
</style>
