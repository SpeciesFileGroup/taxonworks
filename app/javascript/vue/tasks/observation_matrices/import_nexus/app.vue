<template>
  <DocumentSelector
    v-model="nexusDoc"
    class="document_selector"
  />

  <div>Preview uses the same matching options as Convert below</div>
  <div class="preview_button">
    <VBtn
      color="primary"
      medium
      :disabled="!nexusDoc || loadingPreview"
      @click="generatePreview"
    >
      Preview conversion
    </VBtn>

    <span
      v-if="loadingPreview"
      class="inline_spinner"
    >
      <InlineSpinner />
      Parsing nexus file...
    </span>
  </div>

  <ImportPreview
    :otus="nexusTaxaList"
    :descriptors="nexusDescriptorsList"
  />

  <ImportOptions
    v-model="options"
    :doc-chosen="!!nexusDoc"
    :matrix-id="matrixId"
    :matrix-name="matrixName"
    :loading="loadingConvert"
    @convert="scheduleConvert"
  />
</template>

<script setup>
import DocumentSelector from './components/DocumentSelector.vue'
import ImportOptions from './components/ImportOptions.vue'
import ImportPreview from './components/ImportPreview.vue'
import InlineSpinner from './components/InlineSpinner.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { ObservationMatrix } from '@/routes/endpoints'
import { ref } from 'vue'

const nexusDoc = ref()
const nexusTaxaList = ref([])
const nexusDescriptorsList = ref([])
const options = ref({})
const matrixId = ref()
const matrixName = ref()
const loadingPreview = ref(false)
const loadingConvert = ref(false)

function generatePreview() {
  const payload = {
    nexus_document_id: nexusDoc.value.id,
    options: combinedOptions(options.value)
  }
  loadingPreview.value = true
  ObservationMatrix.previewNexus(payload)
    .then(({ body }) => {
      nexusTaxaList.value = body.otus
      nexusDescriptorsList.value = body.descriptors
    })
    .catch(() => {})
    .finally(() => {
      loadingPreview.value = false
    })
}

function scheduleConvert() {
  const payload = {
    nexus_document_id: nexusDoc.value.id,
    options: combinedOptions(options.value)
  }

  loadingConvert.value = true
  ObservationMatrix.initiateImportFromNexus(payload)
    .then(({ body }) => {
      // The returned object isn't an AR matrix.
      matrixId.value = body.matrix_id
      matrixName.value = body.matrix_name
    })
    .catch(() => {})
    .finally(() => {
      loadingConvert.value = false
    })
}

function combinedOptions(options) {
  const h = { ...options, ...options.citation_options }
  delete h.citation_options

  return h
}
</script>

<style lang="scss" scoped>
.document_selector {
  margin-bottom: 2em;
}
.preview_button {
  padding-top: .5em;
  padding-bottom: 2em;
  margin-right: 1.5em;
}
.inline_spinner {
  margin-left: .5em;
}
</style>