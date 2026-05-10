<template>
  <div class="material-examined-task">
    <div
      v-if="!results.length && !isLoading"
      class="feedback"
    >
      <p>No OTUs selected. Open this task from the OTU filter radial linker or OTU navigator.</p>
    </div>

    <template
      v-for="result in results"
      :key="result.otu_id"
    >
      <h2
        v-if="results.length > 1"
        class="otu-label"
      >
        {{ result.label }}
      </h2>
      <div
        v-if="result.text"
        class="material-examined-block"
      >
        <pre class="material-examined-text">{{ result.text }}</pre>
      </div>
      <p
        v-else
        class="feedback"
      >
        No DwC occurrences found for {{ result.label }}.
      </p>
    </template>

    <VSpinner
      v-if="isLoading"
      full-screen
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px' }"
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import qs from 'qs'
import AjaxCall from '@/helpers/ajaxCall'
import VSpinner from '@/components/ui/VSpinner.vue'
import { LinkerStorage } from '@/shared/Filter/utils'

const PREVIEW_URL = '/tasks/otus/material_examined/preview'

const isLoading = ref(false)
const results = ref([])

function getInitialParams() {
  const urlParams = qs.parse(window.location.search, {
    ignoreQueryPrefix: true,
    arrayLimit: 2000
  })
  const stored = LinkerStorage.getParameters()
  LinkerStorage.removeParameters()

  const merged = { ...urlParams, ...stored }
  return Object.keys(merged).length ? merged : null
}

async function loadPreview(params) {
  isLoading.value = true
  results.value = []

  try {
    const response = await AjaxCall('post', PREVIEW_URL, { ...params })
    results.value = response.body.results || []
  } catch (e) {
    console.error('Material examined preview failed:', e)
  } finally {
    isLoading.value = false
  }
}

const initialParams = getInitialParams()
if (initialParams) {
  loadPreview(initialParams)
}
</script>

<style scoped>
.material-examined-task {
  padding: 1em;
  max-width: 900px;
}

.otu-label {
  margin-top: 1.5em;
  margin-bottom: 0.25em;
}

.material-examined-block {
  margin-bottom: 1.5em;
}

.material-examined-text {
  white-space: pre-wrap;
  font-family: inherit;
  background: #f8f8f8;
  border: 1px solid #e0e0e0;
  border-radius: 4px;
  padding: 1em;
  line-height: 1.5;
}
</style>
