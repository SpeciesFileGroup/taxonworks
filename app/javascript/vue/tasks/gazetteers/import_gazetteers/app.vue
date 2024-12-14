<template>
  <VSpinner v-if="isLoading" />

  <DocumentSelector
    v-model="selectedDocs"
    class="document_selector"
  />

  <ShapefileFieldsInputs
    v-model:name="shapeNameField"
    v-model:iso-a2="shapeIsoA2Field"
    v-model:iso-a3="shapeIsoA3Field"
    v-model:is-loading="isLoading"
    :shp-doc="shpDoc"
    :dbf-doc="dbfDoc"
  />

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

  <ImportJobs ref="jobsComponent"/>

</template>

<script setup>
import CitationOptions from './components/CitationOptions.vue'
import DocumentSelector from './components/DocumentSelector.vue'
import ImportJobs from './components/ImportJobs.vue'
import ProjectsChooser from '../components/ProjectsChooser.vue'
import ShapefileFieldsInputs from './components/ShapefileFieldsInputs.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import { Gazetteer } from '@/routes/endpoints'
import { computed, ref } from 'vue'

const selectedDocs = ref([])
const shapeNameField = ref('')
const shapeIsoA2Field = ref('')
const shapeIsoA3Field = ref('')
const isLoading = ref(false)
const citation = ref({})
const selectedProjects = ref([])

const jobsComponent = ref(null)

const processingDisabled = computed(() => {
  return !getFileForExtension('.shp') || !shapeNameField.value
})

const shpDoc = computed(() => {
  return getFileForExtension('.shp')
})

const dbfDoc = computed(() => {
  return getFileForExtension('.dbf')
})

function processShapefile() {
  const shp = getFileForExtension('.shp')
  const shx = getFileForExtension('.shx')
  const dbf = getFileForExtension('.dbf')
  const prj = getFileForExtension('.prj')
  const cpg = getFileForExtension('.cpg')

  if (!validateShapefileFileset({shp, shx, dbf, prj, cpg})) {
    return
  }

  const payload = {
    shapefile: {
      shp_doc_id: shp.id,
      shx_doc_id: shx?.id,
      dbf_doc_id: dbf?.id,
      prj_doc_id: prj?.id,
      cpg_doc_id: cpg?.id,
      name_field: shapeNameField.value,
      iso_a2_field: shapeIsoA2Field.value,
      iso_a3_field: shapeIsoA3Field.value
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
      jobsComponent.value.refresh()
      reset()
    })
    .catch(({ response }) => {
      const message = response['body']['errors']
      // TODO: do something nicer than parsing error strings
      if (message.startsWith('Name error')) {
        shapeNameField.value = ''
      } else if (message.startsWith('Iso_3166_a2 error')) {
        shapeIsoA2Field.value = ''
      } else if (message.startsWith('Iso_3166_a3 error')) {
        shapeIsoA3Field.value = ''
      }
    })
    .finally(() => { isLoading.value = false })
}

function reset() {
  selectedProjects.value = []
  shapeNameField.value = ''
  shapeIsoA2Field.value = ''
  shapeIsoA3Field.value = ''
  selectedDocs.value = []
  citation.value = {}
}

// Warning: this just returns the first found
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
</style>