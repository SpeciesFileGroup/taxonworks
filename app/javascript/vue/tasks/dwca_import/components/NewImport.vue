<template>
  <block-layout
    :warning="!validate">
    <template #header>
      <h3>New import</h3>
    </template>
    <template #body>
      <spinner-component
        full-screen
        legend="Uploading import..."
        v-if="isUploading"/>
      <div class="horizontal-left-content">
        <div class="field label-above">
          <label>Description</label>
          <input
            type="text"
            v-model="description">
        </div>
        <div class="field label-above margin-small-left">
          <label>Dataset type </label>
          <select v-model="rowType">
            <option
              v-for="(value, key) in datasetRowTypes"
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
              v-for="code in codes"
              :key="code"
              :value="code"
            >
              {{ code.toUpperCase() }}
            </option>
          </select>
        </div>
      </div>
      <div>
        <spinner-component
          :show-spinner="false"
          legend="Fill description field first"
          v-if="!validate"/>
        <dropzone
          class="dropzone-card"
          v-help.section.import.dropzone
          @vdropzone-success="success"
          @vdropzone-sending="sending"
          @vdropzone-queue-complete="completeQueue"
          @vdropzone-error="error"
          ref="dwcDropzone"
          id="dropzone-dropzone"
          url="/import_datasets.json"
          :use-custom-dropzone-options="true"
          :dropzone-options="dropzone"/>
      </div>
    </template>
  </block-layout>
</template>

<script>

import Dropzone from 'components/dropzone'
import SpinnerComponent from 'components/spinner'
import DATASET_ROW_TYPES from '../const/datasetRowTypes.js'
import CODES from '../const/nomenclatureCodes.js'
import { capitalize } from 'helpers/strings'
import BlockLayout from 'components/layout/BlockLayout.vue'

export default {
  components: {
    Dropzone,
    SpinnerComponent,
    BlockLayout
  },

  emits: ['onCreate'],

  computed: {
    validate () {
      return this.description.length >= 2
    }
  },

  data () {
    return {
      datasetRowTypes: DATASET_ROW_TYPES,
      codes: Object.values(CODES),
      nomenclatureCode: CODES.ICZN,
      rowType: undefined,
      description: '',
      isUploading: false,
      dropzone: {
        paramName: 'import_dataset[source]',
        url: '/import_datasets.json',
        uploadMultiple: false,
        autoProcessQueue: true,
        parallelUploads: 1,
        timeout: 600000,
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        dictDefaultMessage: 'Drop import file here',
        acceptedFiles: '.zip,.txt,.tsv,.xls,.xlsx,.ods'
      }
    }
  },

  methods: {
    success (file, response) {
      this.$emit('onCreate', response)
      this.$refs.dwcDropzone.removeFile(file)
    },

    sending (file, xhr, formData) {
      this.isUploading = true
      formData.append('import_dataset[description]', this.description)
      formData.append('import_dataset[import_settings][nomenclatural_code]', this.nomenclatureCode)

      if (this.rowType) {
        formData.append('import_dataset[import_settings][row_type]', this.rowType)
      }
    },

    completeQueue (file, response) {
      this.isUploading = false
    },

    error (file, error, xhr) {
      if (typeof error === 'string') {
        TW.workbench.alert.create(`<span data-icon="warning">${error}</span>`, 'error')
      } else {
        TW.workbench.alert.create(Object.keys(error).map(key => `
        <span data-icon="warning">${key}:</span>
        <ul>
          <li>${Array.isArray(error[key])
            ? error[key].map(line => capitalize(line)).join('</li><li>')
            : error[key]}
          </li>
        </ul>`).join(''), 'error')
      }
      this.isUploading = false
      this.$refs.dwcDropzone.dropzone.removeFile(file)
    }
  }
}
</script>
