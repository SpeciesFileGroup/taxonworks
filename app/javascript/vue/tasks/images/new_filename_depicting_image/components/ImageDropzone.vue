<template>
  <VDropzone
    class="dropzone-card"
    ref="dropzoneRef"
    url="/images"
    use-custom-dropzone-options
    :dropzone-options="DROPZONE_CONFIG"
    @vdropzone-success="success"
    @vdropzone-sending="sending"
    @vdropzone-error="error"
  />
</template>

<script setup>
import { ref } from 'vue'
import { getCSRFToken, randomUUID } from '@/helpers'
import VDropzone from '@/components/dropzone.vue'

const images = defineModel({
  type: Array,
  default: () => []
})

const errorImages = defineModel('error', {
  type: Array,
  default: () => []
})
const dropzoneRef = ref(null)

const DROPZONE_CONFIG = {
  paramName: 'image[image_file]',
  url: '/images',
  autoProcessQueue: true,
  parallelUploads: 1,
  timeout: 600000,
  headers: {
    'X-CSRF-Token': getCSRFToken()
  },
  dictDefaultMessage: 'Drop images here',
  acceptedFiles: 'image/*,.heic'
}

function error(file, error) {
  dropzoneRef.value.removeFile(file)
  errorImages.value.push({
    uuid: randomUUID(),
    image: file.dataURL,
    error
  })
  TW.workbench.alert.create(Object.values(error).join('; '), 'error')
}

function success(file, response) {
  const isCreated = images.value.some((item) => item.id === response.id)

  dropzoneRef.value.removeFile(file)

  if (!isCreated) {
    images.value.push(response)
  }
}

function sending(file, xhr, formData) {
  formData.append('image[filename_depicts_object]', true)
}
</script>
