<template>
  <div>
    <spinner-component 
      :full-screen="true"
      legend="Uploading import..."
      v-if="isUploading"/>
    <div class="field">
      <label class="block">Name</label>
      <input 
        type="text"
        v-model="name">
    </div>
    <div>
      <spinner-component 
        :show-spinner="false"
        legend="Fill name field first"
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
      return this.name.length >= 2
    }
  },
  data () {
    return {
      name: '',
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
        acceptedFiles: 'text/*'
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
      formData.append('import_dataset[description]', this.name)
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