<template>
  <div class="panel content full-width">
    <dropzone
      class="dropzone-card separate-bottom"
      @vdropzone-success="success"
      @vdropzone-sending="sending"
      ref="imageDropzone"
      id="image-dropzone"
      url="/images"
      :use-custom-dropzone-options="true"
      :dropzone-options="dropzone"/>
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
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        dictDefaultMessage: 'Drop image here',
        acceptedFiles: 'image/*'
      }
    }
  },
  methods: {
    success (file, response) {
      this.$refs.imageDropzone.removeFile(file)
      this.$emit('created',response)
    },
    sending: function (file, xhr, formData) {
      formData.append('image[sled_image_attributes][metadata]', JSON.stringify([]))
    },
  }
}
</script>

<style>

</style>