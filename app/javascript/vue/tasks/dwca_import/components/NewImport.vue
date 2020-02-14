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
        url="/tasks/dwca_import/upload"
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
        paramName: 'dwc_import[file]',
        url: '/tasks/dwca_import/upload',
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
      this.$refs.dwcDropzone.removeFile(file)
    },
    sending: function (file, xhr, formData) {
      this.isUploading = true
      formData.append('dwc_import[name]', this.name)
    },
    completeQueue(file, response) {
      this.$emit('created', this.firstUploaded)
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