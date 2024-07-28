<template>
  <fieldset class="document_select">
    <legend>Select a Nexus document</legend>
    <VSpinner v-if="isLoading" />
    <SmartSelector
      klass="Documents"
      model="documents"
      v-model="nexusDoc"
      label="document_file_file_name"
      pin-section="Documents"
      pin-type="Document"
      :add-tabs="['new', 'filter']"
      class="selector"
      :filter="(item) => nexusExtensions.some(ext => item.document_file_file_name.endsWith(ext))"
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
          :filter-group-names="['nexus']"
          @filter="() => loadList(parameters)"
        />
        <div class="results">
          <div
            v-for="doc in filterList"
            :key="doc.id"
          >
            <label
              class="cursor-pointer"
              @mousedown="() => nexusDoc = doc"
            >
              <input
                @keyup.enter="() => nexusDoc = doc"
                @keyup.space="() => nexusDoc = doc"
                :checked="nexusDoc && doc.id == nexusDoc.id"
                type="radio"
              />
              {{ doc.document_file_file_name }}
            </label>
          </div>
        </div>
      </template>
    </SmartSelector>
    <SmartSelectorItem
      :item="nexusDoc"
      label="document_file_file_name"
      @unset="() => nexusDoc = undefined"
      class="selector_item"
    />
    <div v-if="noMatchesForExtension === true">
      <i>No documents found matching the selected extensions</i>
    </div>
  </fieldset>
</template>

<script setup>
import Dropzone from '@/components/dropzone.vue'
import FilterDocument from './FilterDocument.vue'
import SmartSelector from '@/components/ui/SmartSelector'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
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
  dictDefaultMessage: 'Drop a nexus file here',
}

const emit = defineEmits('selected')

const nexusDoc = defineModel()

const isPublicDocument = ref(false)
const parameters = ref({})
const filterList = ref([])
const isLoading = ref(true)
const noMatchesForExtension = ref(undefined)
const extensionGroups = ref([])

const nexusExtensions = computed(() => {
  const nexusGroup = extensionGroups.value.find((h) => h['group'] == 'nexus')
  return nexusGroup ? nexusGroup['extensions'] : []
})

const dropzoneConfig = computed(() => {
  return {
    ...DROPZONE_CONFIG_BASE,
    acceptedFiles: nexusExtensions.value.join(', ')
  }
})

function sending(file, xhr, formData) {
  formData.append('document[is_public]', isPublicDocument.value)
}

function success(file, response) {
  // Note: dropzone calls success once for each file dropped, even when multiple are dropped at once - here we always select the last one dropped
  nexusDoc.value = response
  isPublicDocument.value = false
  noMatchesForExtension.value = undefined
}

function loadList(params) {
  params['page'] = 1
  params['per'] = 10

  isLoading.value = true
  Document.filter(params)
    .then(({ body }) => {
      filterList.value = body
      noMatchesForExtension.value = filterList.value.length == 0
    })
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
