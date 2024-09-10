<template>
  <VSpinner v-if="isLoading" />
  <!-- TODO somehwere here display which of the required files have been added, whether they all have the same basename?-->
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

  <div class="process_button">
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
import VSpinner from '@/components/ui/VSpinner.vue'
import { Gazetteer, GazetteerImport } from '@/routes/endpoints'
import { computed, onMounted, ref } from 'vue'

const selectedDocs = ref([])
const shape_name_field = ref('')
const isLoading = ref(false)

const processingDisabled = computed(() => {
  return selectedDocs.value.length != 4 || !shape_name_field.value
})

function processShapefile() {
  const shp = getFileForExtension('.shp')
  const shx = getFileForExtension('.shx')
  const dbf = getFileForExtension('.dbf')
  const prj = getFileForExtension('.prj')

  if (!validateShapefileFileset({shp, shx, dbf, prj})) {
    return
  }

  const payload = {
    shapefile: {
      shp_doc_id: shp.id,
      shx_doc_id: shx.id,
      dbf_doc_id: dbf.id,
      prj_doc_id: prj.id,
      name_field: shape_name_field.value
    }
  }

  isLoading.value = true
  Gazetteer.import(payload)
  .then(() => {
    TW.workbench.alert.create('Import submitted to background job', 'notice')
  })
  .catch(() => {})
  .finally(() => { isLoading.value = false })
}

function getFileForExtension(extension) {
  return selectedDocs.value.find(
    (d) => d.document_file_file_name.endsWith(extension)
  )
}

function validateShapefileFileset(fileset) {
  // Check that all required files are there
  let missingFiles = []
  Object.keys(fileset).map((key) => {
    if (!fileset[key]) {
      missingFiles.push(key)
    }
  })
  missingFiles = missingFiles.join(', ')

  if (missingFiles) {
    TW.workbench.alert.create('Missing files: ' + missingFiles, 'error')
    return false
  }

  // Check that they all have the same basename
  const shpBasename = basename(fileset['shp'])
  Object.keys(fileset).forEach((key) => {
    if (basename(fileset[key]) != shpBasename) {
      TW.workbench.alert.create(
        'All files must have the name ' + shpBasename, 'error'
      )
      return false
    }
  })

  return true
}

// Assumes Document file whose document_file_file_name has a three character
// extension
function basename(file) {
  return file['document_file_file_name'].slice(0, -4)
}

onMounted(() => {
  GazetteerImport.all().then(({ body }) => {

  })
})
</script>

<style lang="scss" scoped>
.document_selector {
  margin-bottom: 2em;
}

.process_button {
  margin-top: 1em;
  margin-bottom: 1em;
}

.results {
  margin-bottom: 1em;
}
</style>