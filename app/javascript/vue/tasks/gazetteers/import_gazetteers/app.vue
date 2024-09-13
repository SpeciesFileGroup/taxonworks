<template>
  <VSpinner v-if="isLoading" />
  <!-- TODO somehwere here display which of the required files have been added, whether they all have the same basename?-->
  <DocumentSelector
    v-model="selectedDocs"
    class="document_selector"
  />

  <div>
    <div>
      Enter the shapefile field containing Gazetteer names or
      <VBtn
        color="primary"
        medium
        @click="() => lookupShapefileFields()"
      >
        Select from shapefile fields
      </VBtn>
    </div>
    <div class="name">
      <input
        type="text"
        class="normal-input name-input"
        v-model="shapeNameField"
      />
    </div>
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

  <ImportJobs ref="jobs"/>

  <VModal
    v-if="modalVisible"
    @close="() => { modalVisible = false }"
  >
    <template #header>
      <h3>Shapefile fields</h3>
    </template>
    <template #body>
      <ul class="no_bullets">
        <li
          v-for="f in shapefileFields"
          :key="f"
        >
          <label >
            <input
              :key="f"
              type="radio"
              name="modal_fields"
              :value="f"
              @click="(e) => setShapefileField(e.target.value)"
            />
            {{ f }}
          </label>
        </li>
      </ul>
    </template>
  </VModal>
</template>

<script setup>
import DocumentSelector from './components/DocumentSelector.vue'
import ImportJobs from './components/ImportJobs.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import { Gazetteer } from '@/routes/endpoints'
import { computed, ref } from 'vue'

const selectedDocs = ref([])
const shapeNameField = ref('')
const isLoading = ref(false)
const modalVisible = ref(false)
const shapefileFields = ref([])

const jobs = ref(null)

const processingDisabled = computed(() => {
  return selectedDocs.value.length != 4 || !shapeNameField.value
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
      name_field: shapeNameField.value
    }
  }

  isLoading.value = true
  Gazetteer.import(payload)
    .then(() => {
      TW.workbench.alert.create('Import submitted to background job', 'notice')
      jobs.value.refresh()
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

function lookupShapefileFields() {
  const dbf = getFileForExtension('.dbf')
  if (!dbf) {
    TW.workbench.alert.create(
      'Select a dbf document first.', 'error'
    )
    return
  }

  const payload = { dbf_doc_id: dbf.id }
  isLoading.value = true
  Gazetteer.shapefile_fields(payload)
    .then(({ body }) => {
      shapefileFields.value = body.shapefile_fields
      modalVisible.value = true
    })
    .catch(() => {})
    .finally(() => {
      isLoading.value = false
    })
}

function setShapefileField(field) {
  shapeNameField.value = field
  modalVisible.value = false
}

</script>

<style lang="scss" scoped>
.document_selector {
  margin-bottom: 2em;
}

.process_button {
  margin-top: 2.5em;
  margin-bottom: 2.5em;
}

.results {
  margin-bottom: 1em;
}
</style>