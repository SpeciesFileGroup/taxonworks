<template>
  <fieldset class="document_select">
    <legend>Shapefile documents</legend>
    <VSpinner v-if="isLoading" />
    <p>
    Select at minimum a .shp document - .shx, .dbf, and .prj documents must be in TaxonWorks but need not be specified here. A .prj document is optional but if your shapefile has one you should upload it to TaxonWorks before importing (it need not be specified here).
  </p>
    <SmartSelector
      klass="Documents"
      model="documents"
      @selected="(d) => addToList(d)"
      label="document_file_file_name"
      pin-section="Documents"
      pin-type="Document"
      :add-tabs="['new', 'filter']"
      class="selector"
      :filter="(item) => shapefileExtensions.some(ext => item.document_file_file_name.endsWith(ext))"
    >
      <template #new>
        <Dropzone
          class="dropzone-card separate-bottom"
          @vdropzone-sending="sending"
          @vdropzone-success="success"
          url="/documents"
          :use-custom-dropzone-options="true"
          :dropzone-options="dropzoneConfig"
        />
        <label>
          <input
            type="checkbox"
            :checked="isPublicDocument"
            v-model="isPublicDocument"
          />
          Is public
        </label>
      </template>
      <template #filter>
        <FilterDocument
          v-model="parameters"
          :extension-groups="extensionGroups"
          :filter-group-names="['shapefile', 'shp', 'shx', 'dbf', 'prj', 'cpg']"
          @filter="() => loadList(parameters)"
        />
        <div class="results">
          <div
            v-for="doc in filterList"
            :key="doc.id"
          >
            <label
              class="cursor-pointer"
              @mousedown="() => addToList(doc)"
            >
              <input
                @keyup.enter="() => addToList(doc)"
                @keyup.space="() => addToList(doc)"
                type="radio"
                name="filtered file list"
              />
              {{ doc.document_file_file_name }}
            </label>
          </div>
        </div>
      </template>
    </SmartSelector>

    <div v-if="noMatchesForExtensions === true">
      <i>No documents found matching the selected extensions</i>
    </div>

    <div
      v-for="doc in shapefileDocs"
      :key="doc.id"
    >
      <SmartSelectorItem
        :item="doc"
        label="document_file_file_name"
        @unset="() => removeFromList(doc)"
        class="selector_item"
      />
    </div>
  </fieldset>
</template>

<script setup>
import Dropzone from '@/components/dropzone.vue'
import FilterDocument from '@/tasks/observation_matrices/import_nexus/components/FilterDocument.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import { addToArray, removeFromArray } from '@/helpers/arrays.js'
import { Document } from '@/routes/endpoints'
import { computed, onMounted, ref } from 'vue'

const DROPZONE_CONFIG_BASE = {
  paramName: 'document[document_file]',
  url: '/documents',
  headers: {
    'X-CSRF-Token': document
      .querySelector('meta[name="csrf-token"]')
      .getAttribute('content')
  },
  dictDefaultMessage: 'Drop a shapefile file here (.shp, .shx, .dbf, .prj, .cpg)',
}

const emit = defineEmits('selected')

const shapefileDocs = defineModel()
shapefileDocs.value = []

const isPublicDocument = ref(false)
const parameters = ref({})
const filterList = ref([])
const isLoading = ref(true)
const noMatchesForExtensions = ref(undefined)
const extensionGroups = ref([])

const shapefileExtensions = computed(() => {
  const shapefileGroup =
    extensionGroups.value.find((h) => h['group'] == 'shapefile')
  if (shapefileGroup) {
    return shapefileGroup['extensions'].map((v => v['extension']))
  } else {
    return []
  }
})

const dropzoneConfig = computed(() => {
  return {
    ...DROPZONE_CONFIG_BASE,
    acceptedFiles: shapefileExtensions.value.join(', ')
  }
})

function addToList(doc) {
  addToArray(shapefileDocs.value, doc)
}

function removeFromList(doc) {
  removeFromArray(shapefileDocs.value, doc)
}

function sending(file, xhr, formData) {
  formData.append('document[is_public]', isPublicDocument.value)
}

function success(file, response) {
  // Note: dropzone calls success once for each file dropped, even when multiple
  // are dropped at once
  shapefileDocs.value.push(response)
  isPublicDocument.value = false
  noMatchesForExtensions.value = undefined
}

function loadList(params) {
  params['page'] = 1
  params['per'] = 10

  isLoading.value = true
  Document.filter(params)
    .then(({ body }) => {
      filterList.value = body
      noMatchesForExtensions.value = filterList.value.length == 0
    })
    .catch(() => {})
    .finally(() => { isLoading.value = false })
}

onMounted(() => {
  Document.file_extensions()
    .then(({ body }) => {
      extensionGroups.value = body['extension_groups']
    })
    .finally(() => { isLoading.value = false })
})
</script>

<style lang="scss" scoped>
.document_select {
  width: 600px;
  margin-top: 2em;
}
.selector {
  padding-bottom: 1em;
}
.selector_item {
  border-top: 1px solid #f5f5f5;
}
.results {
  margin-top: 1.5em;
}
</style>
