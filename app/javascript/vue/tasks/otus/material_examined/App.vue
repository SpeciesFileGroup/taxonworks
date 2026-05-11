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
        v-if="result.html"
        class="material-examined-block"
      >
        <div class="material-examined-toolbar">
          <ButtonClipboard
            :text="result.text"
            title="Copy Markdown to clipboard"
          />
          <a
            :href="`/tasks/dwc_occurrences/filter?otu_id[]=${result.otu_id}`"
            target="_blank"
            rel="noopener"
            class="dwc-filter-link"
          >DwcOccurrences</a>
        </div>
        <div
          class="material-examined-html"
          v-html="result.html"
        />
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
import ButtonClipboard from '@/components/ui/Button/ButtonClipboard.vue'
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

.material-examined-toolbar {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 0.5em;
  margin-bottom: 0.4em;
}

.dwc-filter-link {
  font-size: 0.85em;
}

.material-examined-html {
  background: #f8f8f8;
  border: 1px solid #e0e0e0;
  border-radius: 4px;
  padding: 1em;
  line-height: 1.6;
}
</style>
