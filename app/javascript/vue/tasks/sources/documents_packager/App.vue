<template>
  <div class="documents-packager">
    <PackagerHeader
      v-if="!errorMessage"
      :max-bytes="maxBytes"
      filter-name="Filter sources"
      :can-go-back="!!filterParams"
      @back="goBackToFilter"
    />

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
        filename-prefix="sources_download"
        item-label="docs"
        item-count-key="document_ids"
        empty-message="No documents found in the selected sources."
        @refresh="refreshPreview"
        @download="downloadGroup"
      />

      <PackagerTable
        title="Sources"
        :items="tableRows"
        :columns="tableColumns"
      >
        <template #source="{ item }">
          <a :href="`/sources/${item.source.id}`">Source</a>
          <span class="margin-small-left">{{ item.source.cached }}</span>
        </template>
        <template #document="{ item }">
          <template v-if="item.available">
            <a :href="item.document.url">Doc</a>
            <span class="margin-small-left">{{ item.document.name }}</span>
          </template>
          <span v-else class="unavailable">{{ item.document.name }} (unavailable)</span>
        </template>
      </PackagerTable>
    </div>
  </div>
</template>

<script setup>
import { computed, onBeforeMount, ref } from 'vue'
import qs from 'qs'
import VSpinner from '@/components/ui/VSpinner.vue'
import {
  PackagerHeader,
  PackagerDownloads,
  PackagerTable
} from '@/components/packager'
import ajaxCall from '@/helpers/ajaxCall'
import { LinkerStorage } from '@/shared/Filter/utils'
import { RouteNames } from '@/routes/routes.js'
import {
  STORAGE_FILTER_QUERY_KEY,
  STORAGE_FILTER_QUERY_STATE_PARAMETER
} from '@/constants'
import { randomUUID } from '@/helpers'
import { createAndSubmitForm } from '@/helpers/forms'

const isLoading = ref(false)
const groups = ref([])
const sources = ref([])
const errorMessage = ref('')
const filterParams = ref(null)
const maxBytes = ref(0)
const maxMb = ref(1000)

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

function downloadGroup(index) {
  createAndSubmitForm({
    action: '/tasks/sources/documents_packager/download',
    data: {
      ...(filterParams.value || {}),
      group: index,
      max_mb: maxMb.value
    },
    openTab: true
  })
}

function goBackToFilter() {
  if (!filterParams.value) return

  const uuid = randomUUID()
  localStorage.setItem(
    STORAGE_FILTER_QUERY_KEY,
    JSON.stringify({ [uuid]: filterParams.value })
  )
  window.location.href = `${RouteNames.FilterSources}?${STORAGE_FILTER_QUERY_STATE_PARAMETER}=${uuid}`
}

function loadPreview(params) {
  isLoading.value = true
  errorMessage.value = ''

  ajaxCall('post', '/tasks/sources/documents_packager/preview.json', {
    ...params,
    max_mb: maxMb.value
  })
    .then(({ body }) => {
      sources.value = body.sources || []
      groups.value = body.groups || []
      filterParams.value = body.filter_params || null
      maxBytes.value = body.max_bytes || 0
    })
    .catch(() => {
      errorMessage.value = 'Unable to load sources for packaging.'
    })
    .finally(() => {
      isLoading.value = false
    })
}

onBeforeMount(function () {
  const stored = LinkerStorage.getParameters() || {}
  const params = {
    ...qs.parse(window.location.search, {
      ignoreQueryPrefix: true,
      arrayLimit: 2000
    }),
    ...stored
  }

  LinkerStorage.removeParameters()

  if (!Object.keys(params).length) {
    errorMessage.value = 'no-params'
    return
  }

  loadPreview(params)
})

function refreshPreview() {
  if (!filterParams.value) return
  loadPreview(filterParams.value)
}
</script>

<style scoped>
.unavailable {
  color: var(--text-muted-color);
  font-style: italic;
}
</style>
