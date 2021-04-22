<template>
  <div>
    <spinner-component
      :full-screen="true"
      legend="Uploading import..."
      v-if="isUploading"/>
    <div class="field label-above">
      <label>Description</label>
      <input
        type="text"
        v-model="description">
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
  </div>
</template>

<script>

import Dropzone from 'components/dropzone'
import SpinnerComponent from 'components/spinner'
import { capitalize } from 'helpers/strings'

export default {
  components: {
    Dropzone,
    SpinnerComponent
  },
  computed: {
    validate () {
      return this.description.length >= 2
    }
  },
  data () {
    return {
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
        acceptedFiles: '.zip,.txt,.xls,.xlsx,.ods'
      },
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
    },
    completeQueue (file, response) {
      this.isUploading = false
    },
    error (file, error, xhr) {
      if (typeof error === 'string') {
        TW.workbench.alert.create(`<span data-icon="warning">${error}</span>`, 'error')
      } else {
        TW.workbench.alert.create(Object.keys(error).map(key => {
          return `<span data-icon="warning">${key}:</span> <ul><li>${Array.isArray(error[key]) ? error[key].map(line => capitalize(line)).join('</li><li>') : error[key]}</li></ul>`
        }).join(''), 'error')
      }
      this.isUploading = false
      this.$refs.dwcDropzone.dropzone.removeFile(file)
    }
  }
}
</script>

<style>

</style>
