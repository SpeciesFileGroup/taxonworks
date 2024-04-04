<template>
  <fieldset class="document_select">
    <legend>Select a Nexus document</legend>
    <SmartSelector
      klass="Documents"
      model="documents"
      v-model="nexusDoc"
      label="document_file_file_name"
      pin-section="Documents"
      :add-tabs="['new']"
    >
      <template #new>
        <Dropzone
          class="dropzone-card separate-bottom"
          @vdropzone-sending="sending"
          @vdropzone-success="success"
          url="/documents"
          :use-custom-dropzone-options="true"
          :dropzone-options="DROPZONE_CONFIG"
        />
        <label>
          <input
            type="checkbox"
            :checked="isPublicDocument"
            v-model="isPublicDocument"
          />
          Is public
        </label>
      </template>
    </SmartSelector>
    <SmartSelectorItem
      :item="nexusDoc"
      label="document_file_file_name"
      @unset="() => nexusDoc = undefined"
    />
  </fieldset>
</template>

<script setup>
import Dropzone from '@/components/dropzone.vue'
import SmartSelector from '@/components/ui/SmartSelector'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import { ref } from 'vue'

const DROPZONE_CONFIG = {
  paramName: 'document[document_file]',
  url: '/documents',
  headers: {
    'X-CSRF-Token': document
      .querySelector('meta[name="csrf-token"]')
      .getAttribute('content')
  },
  dictDefaultMessage: 'Drop a Nexus file here',
  acceptedFiles: '.nex, .nxs'
}

const nexusDoc = ref()
const isPublicDocument = ref(false)

function sending(file, xhr, formData) {
  formData.append('document[is_public]', isPublicDocument.value)
}

function success(file, response) {
  nexusDoc.value = response
  isPublicDocument.value = false
}

</script>

<style lang="scss" scoped>
.document_select {
  width: 600px;
  margin-top: 2em;
}
</style>
