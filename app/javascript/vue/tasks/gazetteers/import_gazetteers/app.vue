<template>
  <DocumentSelector
    v-model="selectedDocs"
    class="document_selector"
  />

  <div class="preview_button">
    <VBtn
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
import { ref } from 'vue'

const selectedDocs = ref([])

function processShapefile() {
  // TODO make sure there's only one of each
  // TODO make sure they all have the same basename
  const shp = getFileForExtension('.shp')
  const shx = getFileForExtension('.shx')
  const dbf = getFileForExtension('.dbf')
  const prj = getFileForExtension('.prj')

  const payload = {
    shapefile: {
      shp_doc_id: shp.id,
      shx_doc_id: shx.id,
      dbf_doc_id: dbf.id,
      prj_doc_id: prj.id
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