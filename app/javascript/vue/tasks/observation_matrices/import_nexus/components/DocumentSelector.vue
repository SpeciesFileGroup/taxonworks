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
    >
      <template #new>
        <Dropzone
          class="dropzone-card separate-bottom"
          @vdropzone-sending="sending"
          @vdropzone-success="success"
          url="/documents"
          :use-custom-dropzone-options="true"
          :dropzone-options="DROPZONE_CONFIG"
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
        <div>
          <FilterDocument v-model="parameters" />
          <VBtn
            color="primary"
            medium
            @click="() => loadList(parameters)"
          >
            Search
          </VBtn>
        </div>
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
  </fieldset>
</template>

<script setup>
import Dropzone from '@/components/dropzone.vue'
import FilterDocument from './FilterDocument.vue'
import SmartSelector from '@/components/ui/SmartSelector'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import { Document } from '@/routes/endpoints'
import { ref } from 'vue'

const DROPZONE_CONFIG = {
  paramName: 'document[document_file]',
  url: '/documents',
  headers: {
    'X-CSRF-Token': document
      .querySelector('meta[name="csrf-token"]')
      .getAttribute('content')
  },
  dictDefaultMessage: 'Drop a Nexus file here',
  acceptedFiles: '.nex, .nxs'
}

const emit = defineEmits('selected')

const nexusDoc = defineModel()

const isPublicDocument = ref(false)
const parameters = ref({})
const filterList = ref([])
const isLoading = ref(false)

function sending(file, xhr, formData) {
  formData.append('document[is_public]', isPublicDocument.value)
}

function success(file, response) {
  nexusDoc.value = response
  isPublicDocument.value = false
}

function loadList(params) {
  params['page'] = 1
  params['per'] = 10

  isLoading.value = true
  Document.filter(params)
    .then(({ body }) => {
      filterList.value = body
    })
    .finally(() => {
      isLoading.value = false
    })
}
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
