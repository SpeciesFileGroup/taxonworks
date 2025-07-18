<template>
  <fieldset class="document_select">
    <legend>Shapefile documents</legend>
    <VSpinner v-if="isLoading" />
    <p>
      <b
        >Documents that must be in TaxonWorks: .shp, .shx, .dbf, .prj -
        <i>You need only specify the .shp file here.</i></b
      >
      A .cpg document is optional but if your shapefile has one you should
      upload it to TaxonWorks before importing (it need not be selected here).
    </p>

    <ShapefileUploadHelper
      v-if="currentTab == 'new'"
      :docs="shapefileDocs"
    />

    <SmartSelector
      klass="Documents"
      model="documents"
      v-model="selectedDoc"
      @selected="(d) => addToList(d)"
      @on-tab-selected="(tab) => (currentTab = tab)"
      label="document_file_file_name"
      pin-section="Documents"
      pin-type="Document"
      :add-tabs="['new', 'filter']"
      class="selector"
      :filter="
        (item) =>
          shapefileExtensions.some((ext) =>
            item.document_file_file_name.endsWith(ext)
          )
      "
    >
      <template #new>
        <Dropzone
          class="dropzone-card separate-bottom"
          url="/documents"
          ref="dropzone"
          use-custom-dropzone-options
          :dropzone-options="dropzoneConfig"
          @vdropzone-sending="sending"
          @vdropzone-success="success"
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
              @mousedown="() => addToListFromFilter(doc)"
            >
              <input
                @keyup.enter="() => addToListFromFilter(doc)"
                @keyup.space="() => addToListFromFilter(doc)"
                type="radio"
                name="filtered file list"
                :checked="selectedDoc && doc.id == selectedDoc.id"
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
import ShapefileUploadHelper from './ShapefileUploadHelper.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import { addToArray, removeFromArray } from '@/helpers/arrays.js'
import { Document } from '@/routes/endpoints'
import { computed, onMounted, ref, watch, useTemplateRef } from 'vue'

const DROPZONE_CONFIG_BASE = {
  paramName: 'document[document_file]',
  url: '/documents',
  headers: {
    'X-CSRF-Token': document
      .querySelector('meta[name="csrf-token"]')
      .getAttribute('content')
  },
  dictDefaultMessage:
    'Drop a shapefile file here (.shp, .shx, .dbf, .prj, .cpg)'
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
const selectedDoc = ref(undefined)
const currentTab = ref(undefined)
const dropzoneRef = useTemplateRef('dropzone')

const shapefileExtensions = computed(() => {
  const shapefileGroup = extensionGroups.value.find(
    (h) => h['group'] == 'shapefile'
  )
  if (shapefileGroup) {
    return shapefileGroup['extensions'].map((v) => v['extension'])
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

watch(
  () => shapefileDocs.value.length,
  (newLength) => {
    if (newLength == 0) {
      // Reset
      selectedDoc.value = undefined
    }
  }
)

function addToList(doc) {
  addToArray(shapefileDocs.value, doc)
}

function addToListFromFilter(doc) {
  selectedDoc.value = doc
  addToList(doc)
}

function removeFromList(doc) {
  selectedDoc.value = undefined
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
  dropzoneRef.value.removeFile(file)
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
    .finally(() => {
      isLoading.value = false
    })
}

onMounted(() => {
  Document.file_extensions()
    .then(({ body }) => {
      extensionGroups.value = body['extension_groups']
    })
    .finally(() => {
      isLoading.value = false
    })
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
