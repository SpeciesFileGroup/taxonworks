<template>
  <div class="panel content">
    <VDropzone
      @vdropzone-sending="sending"
      @vdropzone-success="success"
      @vdropzone-queue-complete="isUploading = false"
      ref="dropzoneComponent"
      url="/depictions"
      use-custom-dropzone-options
      :dropzone-options="dropzoneOptions"
    />
    <VSpinner
      v-if="isUploading"
      full-screen
      legend="Uploading images..."
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useStore } from '../store/useStore'
import { COLLECTION_OBJECT } from 'constants/index'
import { ActionNames } from '../store/actions/actions'
import VDropzone from 'components/dropzone.vue'
import VSpinner from 'components/spinner.vue'

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

const store = useStore()
const dropzoneComponent = ref(null)
const isUploading = ref(false)

const unsubscribe = store.$onAction(
  ({
    name,
    after
  }) => {
    if (name !== ActionNames.CreateNewSpecimen) {
      return
    }

    after(_ => {
      if (dropzoneComponent.value.dropzone.getQueuedFiles().length) {
        isUploading.value = true
        dropzoneComponent.value.processQueue()
      }
    })
  })

const success = (file) => {
  dropzoneComponent.value.removeFile(file)
}

const sending = (file, xhr, formData) => {
  formData.append('depiction[depiction_object_id]', store.createdCO.id)
  formData.append('depiction[depiction_object_type]', COLLECTION_OBJECT)
}

</script>
