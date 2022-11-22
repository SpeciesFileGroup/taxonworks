<template>
  <div class="panel content">
    <VDropzone
      @vdropzone-sending="sending"
      @vdropzone-file-added="addedfile"
      @vdropzone-success="success"
      @vdropzone-error="error"
      ref="dropzoneComponent"
      url="/depictions"
      use-custom-dropzone-options
      :dropzone-options="dropzoneOptions"
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import VDropzone from 'components/dropzone.vue'

const dropzoneOptions = {
  paramName: 'depiction[image_attributes][image_file]',
  url: '/depictions',
  autoProcessQueue: false,
  addRemoveLinks: true,
  headers: {
    'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
  },
  dictDefaultMessage: 'Drop image or click to browse',
  acceptedFiles: 'image/*,.heic'
}

const dropzoneComponent = ref(null)

</script>
