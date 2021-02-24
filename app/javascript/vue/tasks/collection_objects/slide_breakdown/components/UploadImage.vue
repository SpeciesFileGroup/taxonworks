<template>
  <div class="panel  full-width">
    <div class="content">
      <dropzone
        class="dropzone-card"
        @vdropzone-success="success"
        @vdropzone-sending="sending"
        @vdropzone-queue-complete="completeQueue"
        ref="imageDropzone"
        id="image-dropzone"
        url="/images"
        :use-custom-dropzone-options="true"
        :dropzone-options="dropzone"/>
    </div>
  </div>
</template>

<script>

import Dropzone from 'components/dropzone'

export default {
  components: {
    Dropzone
  },
  data () {
    return {
      dropzone: {
        paramName: 'image[image_file]',
        url: '/images',
        uploadMultiple: false,
        autoProcessQueue: true,
        parallelUploads: 1,
        timeout: 600000,
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        dictDefaultMessage: 'Drop image here',
        acceptedFiles: 'image/*'
      },
      firstUploaded: undefined
    }
  },
  methods: {
    success (file, response) {
      this.$refs.imageDropzone.removeFile(file)
      if(!this.firstUploaded) {
        this.firstUploaded = response
      }
    },
    sending: function (file, xhr, formData) {
      formData.append('image[sled_image_attributes][metadata]', '[]')
    },
    completeQueue(file, response) {
      this.$emit('created', this.firstUploaded)
      this.firstUploaded = undefined
    }
  }
}
</script>

<style>

</style>
