<template>
  <VSpinner v-if="isLoading" />
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

  <CitationOptions
    v-model="citation"
    class="citations_options"
  />

  <ProjectsChooser
    v-model="selectedProjects"
    selection-text="Gazetteers will be imported into each selected project."
    class="projects_chooser"
  />

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
    @close="() => {
      modalVisible = false
      modalNameSelection = ''
    }"
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
              v-model="modalNameSelection"
            />
            {{ f }}
          </label>
        </li>
      </ul>
      <VBtn
        :disabled="!modalNameSelection"
        medium
        color="primary"
        @click="() => setShapefileField()"
        class="modal-button"
      >
        Select name field
      </VBtn>
    </template>
  </VModal>
</template>

<script setup>
import CitationOptions from './components/CitationOptions.vue'
import DocumentSelector from './components/DocumentSelector.vue'
import ImportJobs from './components/ImportJobs.vue'
import ProjectsChooser from '../components/ProjectsChooser.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import { Gazetteer } from '@/routes/endpoints'
import { computed, ref } from 'vue'

const selectedDocs = ref([])
const shapeNameField = ref('')
const isLoading = ref(false)
const modalVisible = ref(false)
const modalNameSelection = ref('')
const shapefileFields = ref([])
const citation = ref({})
const selectedProjects = ref([])

const jobs = ref(null)

const processingDisabled = computed(() => {
  return !getFileForExtension('.shp') || !shapeNameField.value
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
      shx_doc_id: shx?.id,
      dbf_doc_id: dbf?.id,
      prj_doc_id: prj?.id,
      name_field: shapeNameField.value
    },
    citation_options: {
      cite_gzs: !!citation.value.source_id,
      citation: citation.value
    },
    projects: selectedProjects.value
  }

  isLoading.value = true
  Gazetteer.import(payload)
    .then(() => {
      TW.workbench.alert.create('Import submitted to background job', 'notice')
      jobs.value.refresh()
      reset()
    })
    .catch(() => {})
    .finally(() => { isLoading.value = false })
}

function reset() {
  selectedProjects.value = []
  shapefileFields.value = []
  shapeNameField.value = ''
  selectedDocs.value = []
  citation.value = {}
}

function getFileForExtension(extension) {
  return selectedDocs.value.find(
    (d) => d.document_file_file_name.endsWith(extension)
  )
}

function validateShapefileFileset(fileset) {
  if (!fileset['shp']) {
    TW.workbench.alert.create(
      'A .shp file is required', 'error'
    )
    return false
  }

  const shpBasename = basename(fileset['shp'])
  if (
    selectedDocs.value.some((d) => {
      return basename(d) != shpBasename
    })
  ) {
    TW.workbench.alert.create(
      'All selected documents must use the same name', 'error'
    )
    return false
  }

  return true
}

// Assumes Document file whose document_file_file_name has a three character
// extension
function basename(file) {
  return file ? file['document_file_file_name'].slice(0, -4) : undefined
}

function lookupShapefileFields() {
  const shp = getFileForExtension('.shp')
  const dbf = getFileForExtension('.dbf')
  if (!shp && !dbf) {
    TW.workbench.alert.create(
      'Select a .shp (or .dbf) document first.', 'error'
    )
    return
  }

  const payload = {
    shp_doc_id: shp?.id,
    dbf_doc_id: dbf?.id
  }
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

function setShapefileField() {
  shapeNameField.value = modalNameSelection.value
  modalVisible.value = false
  modalNameSelection.value = ''
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

.citations_options {
  max-width: 600px;
  margin-top: 2em;
  margin-bottom: 2em;
}

.projects_chooser {
  max-width: 600px;
}

.modal-button {
  margin-top: 1.5em;
}
</style>