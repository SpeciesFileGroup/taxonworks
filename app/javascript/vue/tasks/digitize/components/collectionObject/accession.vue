<template>
  <div>
    <VBtn
      medium
      color="primary"
      variant="tonal"
      @click="setModalState(true)"
    >
      Accession metadata
    </VBtn>
    <VModal
      v-if="showModal"
      @close="setModalState(false)"
    >
      <template #header>
        <h3>Accession metadata</h3>
      </template>
      <template #body>
        <div class="field">
          <label> Accessioned at </label><br />
          <input
            type="date"
            class="full_width"
            @change="unsaved = true"
            v-model="collectionObject.accessioned_at"
          />
        </div>
        <div class="field">
          <label> Deaccessioned at </label><br />
          <input
            type="date"
            class="full_width"
            @change="unsaved = true"
            v-model="collectionObject.deaccessioned_at"
          />
        </div>
        <div class="field">
          <label> Deaccession reason </label><br />
          <input
            type="text"
            class="full_width"
            @change="unsaved = true"
            v-model="collectionObject.deaccession_reason"
          />
        </div>
        <button
          type="button"
          @click="saveAccession"
          class="button normal-input button-submit"
        >
          Save
        </button>
      </template>
    </VModal>
  </div>
</template>

<script setup>
import VModal from '@/components/ui/Modal'
import VBtn from '@/components/ui/VBtn/index.vue'
import { ActionNames } from '../../store/actions/actions'
import { useStore } from 'vuex'
import { ref } from 'vue'

const store = useStore()
const showModal = ref(false)
const unsaved = ref(false)

const props = defineProps({
  collectionObject: {
    type: Object,
    required: true
  }
})

function saveAccession() {
  store
    .dispatch(ActionNames.SaveCollectionObject, props.collectionObject)
    .then(() => {
      TW.workbench.alert.create(
        'Collection object was successfully saved.',
        'notice'
      )
      unsaved.value = false
    })
}

function checkUnsaved() {
  if (
    unsaved.value &&
    window.confirm('You have unsaved changes. Do you want to save it?')
  ) {
    saveAccession()
  }
}

function setModalState(value) {
  checkUnsaved()
  showModal.value = value
}
</script>

<style scoped>
:deep(.modal-container) {
  width: 300px !important;
}
</style>
