<template>
  <BlockLayout :warning="!validate">
    <template #header>
      <h3>New import</h3>
    </template>
    <template #body>
      <VSpinner
        full-screen
        legend="Uploading import..."
        v-if="isUploading"
      />
      <div class="horizontal-left-content">
        <div class="field label-above">
          <label>Description</label>
          <input
            type="text"
            v-model="description"
          />
        </div>
        <div class="field label-above margin-small-left">
          <label>Dataset type </label>
          <select v-model="rowType">
            <option
              v-for="(value, key) in DATASET_ROW_TYPES"
              :key="key"
              :value="value"
            >
              {{ key }}
            </option>
          </select>
        </div>
        <div class="field label-above margin-small-left">
          <label>Nomenclature code: </label>
          <select v-model="nomenclatureCode">
            <option
              v-for="code in CODES"
              :key="code"
              :value="code"
            >
              {{ code.toUpperCase() }}
            </option>
          </select>
        </div>
      </div>
      <div>
        <VSpinner
          :show-spinner="false"
          legend="Fill description field first"
          v-if="!validate"
        />
        <VDropzone
          class="dropzone-card"
          v-help.section.import.dropzone
          ref="dwcDropzone"
          id="dropzone-dropzone"
          url="/import_datasets.json"
          use-custom-dropzone-options
          :dropzone-options="dropzone"
          @vdropzone-success="success"
          @vdropzone-sending="sending"
          @vdropzone-error="error"
          @vdropzone-queue-complete="completeQueue"
          @vdropzone-file-added="addedFile"
        />
      </div>
    </template>
  </BlockLayout>
  <DelimiterModal
    v-if="isDelimiterModalOpen"
    v-model="delimiters"
    @submit="
      () => {
        dwcDropzone.dropzone.processQueue()
        isDelimiterModalOpen = false
      }
    "
    @close="() => closeModal()"
  />
</template>

<script setup>
import { computed, ref } from 'vue'
import { capitalize } from '@/helpers/strings'
import VDropzone from '@/components/dropzone'
import VSpinner from '@/components/ui/VSpinner'
import DATASET_ROW_TYPES from '../const/datasetRowTypes.js'
import CODES from '../const/nomenclatureCodes.js'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import DelimiterModal from './DelimiterModal.vue'

const emit = defineEmits(['onCreate'])
const TEXT_TYPES = ['text/plain']

const validate = computed(() => description.value.length >= 2)
const nomenclatureCode = ref(CODES.ICZN)
const description = ref('')
const isUploading = ref(false)
const rowType = ref()
const dwcDropzone = ref(null)
const isDelimiterModalOpen = ref(false)
const delimiters = ref(initDelimiters())

const dropzone = {
  paramName: 'import_dataset[source]',
  url: '/import_datasets.json',
  uploadMultiple: false,
  autoProcessQueue: false,
  parallelUploads: 1,
  timeout: 600000,
  headers: {
    'X-CSRF-Token': document
      .querySelector('meta[name="csrf-token"]')
      .getAttribute('content')
  },
  dictDefaultMessage: 'Drop import file here',
  acceptedFiles: '.zip,.txt,.tsv,.xls,.xlsx,.ods'
}

function initDelimiters() {
  return { field: null, str: null }
}

function success(file, response) {
  emit('onCreate', response)
  dwcDropzone.value.removeFile(file)
}

function sending(file, xhr, formData) {
  isUploading.value = true
  formData.append('import_dataset[description]', description.value)
  formData.append(
    'import_dataset[import_settings][nomenclatural_code]',
    nomenclatureCode.value
  )

  if (rowType.value) {
    formData.append('import_dataset[import_settings][row_type]', rowType.value)
  }

  if (delimiters.value.field) {
    formData.append('import_dataset[col_sep]', delimiters.value.field)
  }
  if (delimiters.value.str) {
    formData.append('import_dataset[quote_char]', delimiters.value.str)
  }
}

function completeQueue(file, response) {
  isUploading.value = false
  delimiters.value = initDelimiters()
}

function addedFile(file) {
  if (TEXT_TYPES.includes(file.type)) {
    isDelimiterModalOpen.value = true
  }
}

function closeModal() {
  isDelimiterModalOpen.value = false
  if (!isUploading.value) {
    dwcDropzone.value.dropzone.removeAllFiles()
  }
}

function error(file, error, xhr) {
  if (typeof error === 'string') {
    TW.workbench.alert.create(
      `<span data-icon="warning">${error}</span>`,
      'error'
    )
  } else {
    TW.workbench.alert.create(
      Object.keys(error)
        .map(
          (key) => `
        <span data-icon="warning">${key}:</span>
        <ul>
          <li>${
            Array.isArray(error[key])
              ? error[key].map((line) => capitalize(line)).join('</li><li>')
              : error[key]
          }
          </li>
        </ul>`
        )
        .join(''),
      'error'
    )
  }
  isUploading.value = false
  dwcDropzone.value.dropzone.removeFile(file)
}
</script>
