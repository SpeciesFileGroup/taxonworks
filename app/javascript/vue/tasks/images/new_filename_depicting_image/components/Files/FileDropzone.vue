<template>
  <VDropzone
    ref="dropzoneRef"
    class="filename-depiction-dropzone"
    url="/depictions"
    use-custom-dropzone-options
    :add-remove-button="false"
    :dropzone-options="DROPZONE_CONFIG"
    @vdropzone-file-added="(file) => store.addFiles([file])"
    @vdropzone-sending="sending"
    @vdropzone-success="success"
    @vdropzone-error="error"
    @vdropzone-queue-complete="emit('complete')"
  />
</template>

<script setup>
import { useTemplateRef } from 'vue'
import { getCSRFToken } from '@/helpers'
import { STATUS } from '../../constants'
import { useStore } from '../../store/store'
import VDropzone from '@/components/dropzone.vue'

const DROPZONE_CONFIG = {
  paramName: 'depiction[image_attributes][image_file]',
  url: '/depictions',
  autoQueue: false,
  autoProcessQueue: true,
  parallelUploads: 1,
  timeout: 600000,
  createImageThumbnails: false,
  headers: {
    'X-CSRF-Token': getCSRFToken()
  },
  dictDefaultMessage: 'Drop images here',
  acceptedFiles: 'image/*,.heic'
}

const emit = defineEmits(['complete'])

const store = useStore()
const dropzoneRef = useTemplateRef('dropzoneRef')

function getDropzone() {
  return dropzoneRef.value.getDropzone()
}

function enqueue(file) {
  if (!file.accepted) return

  const dropzone = getDropzone()

  file.status = dropzone.constructor.ADDED
  dropzone.enqueueFile(file)
}

function remove(file) {
  getDropzone().removeFile(file)
}

function removeAll() {
  dropzoneRef.value.removeAllFiles()
}

function sending(file, xhr, formData) {
  const row = store.findRowByFile(file)
  const { collection_object_id, figure_label, caption } = row.upload.match

  row.upload.status = STATUS.Uploading

  formData.append('depiction[depiction_object_id]', collection_object_id)
  formData.append('depiction[depiction_object_type]', 'CollectionObject')

  if (figure_label) {
    formData.append('depiction[figure_label]', figure_label)
  }

  if (caption) {
    formData.append('depiction[caption]', caption)
  }
}

function success(file, response) {
  const row = store.findRowByFile(file)

  if (row) {
    store.setUploadResponse(row, response)
  }
}

function error(file, message) {
  const row = store.findRowByFile(file)

  if (row) {
    store.setUploadError(row, message)
  }
}

defineExpose({
  enqueue,
  remove,
  removeAll
})
</script>

<style scoped>
.filename-depiction-dropzone :deep(.dz-preview) {
  display: none;
}

.filename-depiction-dropzone.dz-started :deep(.dz-message) {
  display: block;
}
</style>
