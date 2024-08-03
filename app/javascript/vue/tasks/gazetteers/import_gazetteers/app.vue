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

  <div class="results">
    <!-- Perma-displaying this so it doesn't get populated below the fold with
         no notice that that's happened -->
    <fieldset>
      <legend>Import results</legend>
      <div v-if="results">
        <p>
          Number of shapefile records: {{ results['num_records'] }}
        </p>
        <p>
          Number of gazetteers created: {{ results['num_gzs_created'] }}
        </p>
        <p v-if="results['num_gzs_created'] < results['num_records']">
          Aborted? {{ results['aborted'] ? 'Yes' : 'No' }}
        </p>
        <p v-if="resultErrors">
          <p>Errors, written "record number: error message":</p>
          <ul>
            <li
              v-for="error in resultErrors"
              :key="error"
            >
              {{ error }}
            </li>
          </ul>
        </p>
      </div>
      <p v-else>
        No shapefiles processed
      </p>
    </fieldset>
  </div>

</template>

<script setup>
import DocumentSelector from './components/DocumentSelector.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import { Gazetteer } from '@/routes/endpoints'
import { computed, ref } from 'vue'

const SHAPEFILE_EXTENSIONS = ['.shp', '.shx', '.dbf', '.prj']

const selectedDocs = ref([])
const shape_name_field = ref('')
const results = ref(null)
const isLoading = ref(false)

const processingDisabled = computed(() => {
  return selectedDocs.value.length != 4 || !shape_name_field.value
})

const resultErrors = computed(() => {
  if (results.value == null || results.value['error_ids'].length == 0) {
    return null
  }

  let a = []
  results.value['error_ids'].forEach((id, i) => {
    a.push(id + ': ' + results.value['error_messages'][i])
  })

  return a
})

function processShapefile() {
  results.value = null
  // TODO report fail if prj provided and not WGS84, but don't require prj
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
  .then(({ body }) => {
    results.value = body
    // TODO: maybe clear currently selected shape files?
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

// Assumes Document file whose document_file_file_name has a '.eee' extension
function basename(file) {
  return file['document_file_file_name'].slice(0, -4)
}
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