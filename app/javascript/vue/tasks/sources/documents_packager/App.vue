<template>
  <div class="documents-packager">
    <VSpinner
      v-if="isLoading"
      full-screen
      legend="Preparing downloads..."
    />

    <div v-if="errorMessage && !isLoading">
      <p v-if="errorMessage === 'no-params'" class="feedback feedback-warning">
        No source filter parameters were found. Launch this task from
        <a :href="RouteNames.FilterSources">Filter Sources</a>
        using the right side linker radial.
      </p>
      <p v-else class="feedback feedback-warning">{{ errorMessage }}</p>
    </div>

    <div v-if="!isLoading && !errorMessage">
      <PackagerDownloads
        :groups="groups"
        v-model:max-mb="maxMb"
        filter-name="Filter sources"
        :can-go-back="!!filterParams"
        :show-back="!errorMessage"
        filename-prefix="sources_download"
        item-label="docs"
        item-count-key="document_ids"
        empty-message="No documents found in the selected sources."
        @refresh="refreshPreview"
        @download="downloadGroup"
        @back="goBackToFilter"
      />

      <PackagerTable
        title="Sources"
        :items="tableRows"
        :columns="tableColumns"
      >
        <template #source="{ item }">
          <a :href="`/sources/${item.source.id}`" target="_blank" rel="noopener">Source</a>
          <span class="margin-small-left">{{ item.source.cached }}</span>
        </template>
        <template #document="{ item }">
          <template v-if="item.available">
            <a :href="item.document.url" target="_blank" rel="noopener">Doc</a>
            <span class="margin-small-left">{{ item.document.name }}</span>
          </template>
          <span v-else class="unavailable">{{ item.document.name }} (unavailable)</span>
        </template>
      </PackagerTable>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import {
  PackagerDownloads,
  PackagerTable,
  usePackager
} from '@/components/packager'
import { RouteNames } from '@/routes/routes.js'
import {
  STORAGE_FILTER_QUERY_KEY,
  STORAGE_FILTER_QUERY_STATE_PARAMETER
} from '@/constants'

const {
  isLoading,
  groups,
  items: sources,
  errorMessage,
  filterParams,
  maxMb,
  refreshPreview,
  downloadGroup,
  goBackToFilter
} = usePackager({
  previewUrl: '/tasks/sources/documents_packager/preview.json',
  downloadUrl: '/tasks/sources/documents_packager/download',
  filterRoute: RouteNames.FilterSources,
  storageKey: STORAGE_FILTER_QUERY_KEY,
  storageStateParam: STORAGE_FILTER_QUERY_STATE_PARAMETER,
  payloadKey: 'sources',
  loadErrorMessage: 'Unable to load sources for packaging.'
})

const tableColumns = [
  { title: 'Source', slot: 'source' },
  { title: 'Document', slot: 'document' }
]

const tableRows = computed(() => {
  const rows = []
  const sorted = [...sources.value].sort((a, b) => a.id - b.id)

  sorted.forEach((source) => {
    source.documents.forEach((doc) => {
      rows.push({
        id: `source-${source.id}-doc-${doc.id}`,
        source,
        document: doc,
        group_index: doc.group_index,
        size: doc.size,
        available: doc.available
      })
    })
  })

  return rows
})

</script>

<style scoped>
.unavailable {
  color: var(--text-muted-color);
  font-style: italic;
}
</style>
