<template>
  <div>
    <VDropzone
      class="dropzone-card separate-bottom"
      @vdropzone-sending="sending"
      @vdropzone-success="success"
      ref="dropzone"
      url="/sounds"
      use-custom-dropzone-options
      :dropzone-options="DROPZONE_CONFIG"
    />
  </div>
</template>

<script setup>
import { useTemplateRef } from 'vue'
import { getCSRFToken } from '@/helpers'
import VDropzone from '@/components/dropzone.vue'

const DROPZONE_CONFIG = {
  paramName: 'conveyance[sound_attributes][sound_file]',
  url: '/conveyances',
  headers: {
    'X-CSRF-Token': getCSRFToken()
  },
  dictDefaultMessage: 'Drop sounds here',
  acceptedFiles: 'audio/*'
}

const props = defineProps({
  objectId: {
    type: Number,
    required: true
  },

  objectType: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['add'])
const dropzoneRef = useTemplateRef('dropzone')

function success(file, response) {
  emit('add', response)
  dropzoneRef.value.removeFile(file)
}

function sending(file, xhr, formData) {
  formData.append('conveyance[conveyance_object_type]', props.objectType)
  formData.append('conveyance[conveyance_object_id]', props.objectId)
}
</script>
