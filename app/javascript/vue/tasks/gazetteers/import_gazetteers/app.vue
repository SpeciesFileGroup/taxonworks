<template>
  <DocumentSelector
    v-model="selectedDocs"
    class="document_selector"
  />

  <div class="field label-above">
    <label>Name field from shapefile</label>
    <input
      type="text"
      class="normal-input name-input"
      v-model="shape_name_field"
    />
  </div>

  <div class="preview_button">
    <VBtn
      :disabled="processingDisabled"
      color="primary"
      medium
      @click="processShapefile"
    >
      Process shapefile
    </VBtn>
    </div>

</template>

<script setup>
import DocumentSelector from './components/DocumentSelector.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { Gazetteer } from '@/routes/endpoints'
import { computed, ref } from 'vue'

const selectedDocs = ref([])
const shape_name_field = ref('')

const processingDisabled = computed(() => {
  return selectedDocs.value.length != 4 || !shape_name_field.value
})

function processShapefile() {
  // TODO make sure there's only one of each
  // TODO make sure they all have the same basename, I guess
  const shp = getFileForExtension('.shp')
  const shx = getFileForExtension('.shx')
  const dbf = getFileForExtension('.dbf')
  const prj = getFileForExtension('.prj')

  const payload = {
    shapefile: {
      shp_doc_id: shp.id,
      shx_doc_id: shx.id,
      dbf_doc_id: dbf.id,
      prj_doc_id: prj.id,
      name_field: shape_name_field.value
    }
  }

  Gazetteer.import(payload)
}

function getFileForExtension(extension) {
  return selectedDocs.value.find(
    (d) => d.document_file_file_name.endsWith(extension)
  )
}
</script>

<style lang="scss" scoped>
.document_selector {
  margin-bottom: 2em;
}
</style>