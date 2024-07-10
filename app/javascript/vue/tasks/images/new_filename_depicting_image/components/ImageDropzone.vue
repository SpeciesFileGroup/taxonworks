<template>
  <VDropzone
    class="dropzone-card"
    ref="dropzoneRef"
    url="/images"
    use-custom-dropzone-options
    :dropzone-options="DROPZONE_CONFIG"
    @vdropzone-success="success"
    @vdropzone-sending="sending"
  />
  <div
    class="flex-wrap-row separate-top"
    v-if="images.length"
  >
    <ImageViewer
      v-for="item in images"
      :key="item.id"
      :image="item"
      @delete="(e) => emit('remove', e)"
    />
    <div
      data-icon="reset"
      class="reset-button"
      @click="clearImages"
    >
      <span>Clear images</span>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { getCSRFToken } from '@/helpers'
import VDropzone from '@/components/dropzone.vue'
import ImageViewer from '@/components/ui/ImageViewer/ImageViewer.vue'

const images = defineModel({
  type: Array,
  default: () => []
})

const emit = defineEmits(['remove', 'created', 'update:modelValue'])
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

<style scoped>
.reset-button {
  margin: 4px;
  width: 100px;
  height: 65px;
  padding: 0px;
  padding-top: 10px;
  background-position: center;
  background-position-y: 30px;
  background-size: 30px;
  text-align: center;
}
.reset-button:hover {
  opacity: 0.8;
  cursor: pointer;
}
</style>
