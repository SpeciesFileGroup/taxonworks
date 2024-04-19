<template>
  <DocumentSelector v-model="nexusDoc" />

  <VBtn
    color="primary"
    medium
    :disabled="!nexusDoc"
    @click="generatePreview"
    class="button"
  >
    Preview conversion
  </VBtn>

  <ImportPreview
    :otus="nexusTaxaList"
    :descriptors="nexusDescriptorsList"
  />

  <ImportOptions
    v-model="options"
    :doc-chosen="!!nexusDoc"
    :matrix-id="matrixId"
    :matrix-name="matrixName"
    @convert="scheduleConvert"
  />
</template>

<script setup>
import DocumentSelector from './components/DocumentSelector.vue'
import ImportOptions from './components/ImportOptions.vue'
import ImportPreview from './components/ImportPreview.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { ObservationMatrix } from '@/routes/endpoints'
import { ref } from 'vue'

const nexusDoc = ref()
const nexusTaxaList = ref([])
const nexusDescriptorsList = ref([])
const options = ref({})
const matrixId = ref()
const matrixName = ref()

function generatePreview() {
  const payload = {
    nexus_document_id: nexusDoc.value.id,
    options: options.value
  }

  ObservationMatrix.previewNexus(payload)
    .then(({ body }) => {
      nexusTaxaList.value = body.otus
      nexusDescriptorsList.value = body.descriptors
    })
    .catch(() => {})
}

function scheduleConvert() {
  const payload = {
    nexus_document_id: nexusDoc.value.id,
    options: options.value
  }

  ObservationMatrix.initiateImportFromNexus(payload)
    .then(({ body }) => {
      // The returned object isn't an AR matrix.
      matrixId.value = body.matrix_id
      matrixName.value = body.matrix_name
    })
    .catch(() => {})
}
</script>

<style lang="scss" scoped>
.button {
  margin-top: 2em;
  margin-bottom: 2em;
}
</style>