<template>
  <div class="panel content full-width">
    <SmartSelector
      model="images"
      default="new"
      :target="COLLECTION_OBJECT"
      :autocomplete="false"
      :search="false"
      :add-tabs="['new']"
      pin-section="Images"
      :pin-type="IMAGE"
      @selected="(item) => emit('created', item)"
    >
      <template #new>
        <VDropzone
          ref="imageDropzoneRef"
          url="/images"
          use-custom-dropzone-options
          :dropzone-options="DROPZONE_CONFIG"
          @vdropzone-success="success"
          @vdropzone-sending="sending"
          @vdropzone-queue-complete="completeQueue"
        />
      </template>
    </SmartSelector>
  </div>
</template>

<script setup>
import { ref, useTemplateRef } from 'vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import VDropzone from '@/components/dropzone'
import { COLLECTION_OBJECT, IMAGE } from '@/constants'

const dropzoneRef = useTemplateRef('imageDropzoneRef')
const firstUploaded = ref()

const emit = defineEmits(['created'])

const DROPZONE_CONFIG = {
  paramName: 'image[image_file]',
  url: '/images',
  uploadMultiple: false,
  autoProcessQueue: true,
  parallelUploads: 1,
  timeout: 600000,
  headers: {
    'X-CSRF-Token': document
      .querySelector('meta[name="csrf-token"]')
      .getAttribute('content')
  },
  dictDefaultMessage: 'Drop image here',
  acceptedFiles: 'image/*,.heic'
}

function success(file, response) {
  dropzoneRef.value.removeFile(file)
  if (!firstUploaded.value) {
    firstUploaded.value = response
  }
}

function sending(file, xhr, formData) {
  formData.append('image[sled_image_attributes][metadata]', '[]')
}

function completeQueue() {
  emit('created', firstUploaded.value)
  firstUploaded.value = undefined
}
</script>
