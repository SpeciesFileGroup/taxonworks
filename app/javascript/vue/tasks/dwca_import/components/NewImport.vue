<template>
  <div>
    <spinner-component 
      :full-screen="true"
      legend="Uploading import..."
      v-if="isUploading"/>
    <div class="field">
      <label class="block">Description</label>
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
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        dictDefaultMessage: 'Drop import file here',
        acceptedFiles: 'text/*,.zip'
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
    error () {
      this.isUploading = false
    }
  }
}
</script>

<style>

</style>