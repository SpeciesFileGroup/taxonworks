<template>
  <div class="field">
    <VDropzone
      class="dropzone-card"
      ref="dropzone"
      id="source-document"
      url="/documentation"
      use-custom-dropzone-options
      :dropzone-options="DROPZONE_CONFIG"
      @vdropzone-sending="sending"
      @vdropzone-success="success"
    />
  </div>
</template>

<script setup>
import { useTemplateRef } from 'vue'
import { useStore } from 'vuex'
import { MutationNames } from '../../store/mutations/mutations'
import VDropzone from '@/components/dropzone.vue'
const store = useStore()

const props = defineProps({
  isPublic: {
    type: Boolean,
    required: true
  },

  source: {
    type: Object,
    required: true
  }
})

const dropzoneRef = useTemplateRef('dropzone')

const DROPZONE_CONFIG = {
  timeout: 0,
  maxFilesize: 512,
  paramName: 'documentation[document_attributes][document_file]',
  url: '/documentation',
  headers: {
    'X-CSRF-Token': document
      .querySelector('meta[name="csrf-token"]')
      .getAttribute('content')
  },
  dictDefaultMessage: 'Drop documents here',
  acceptedFiles: 'application/pdf, text/plain'
}

function success(file, response) {
  store.commit(MutationNames.AddDocumentation, response)
  TW.workbench.alert.create('Documentation was successfully created.', 'notice')
  dropzoneRef.value.removeFile(file)
}

function sending(file, xhr, formData) {
  formData.append(
    'documentation[annotated_global_entity]',
    decodeURIComponent(props.source.global_id)
  )
  formData.append(
    'documentation[document_attributes][is_public]',
    props.isPublic
  )
}
</script>
