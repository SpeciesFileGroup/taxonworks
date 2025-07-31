<template>
  <div class="horizontal-left-content gap-small">
    <VSpinner
      v-if="isSaving"
      full-screen
      legend="Saving"
    />
    <VBtn
      color="create"
      medium
      :disabled="!!store.collectionObject.id"
      @click="save"
    >
      Save
    </VBtn>

    <VBtn
      color="create"
      medium
      :disabled="!!store.collectionObject.id"
      title="Save and add a new collection object"
      @click="saveAndNew"
    >
      Save and new collecting object
    </VBtn>

    <VBtn
      color="primary"
      medium
      title="Add a new collection object"
      @click="resetStore"
    >
      New collection object
    </VBtn>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import useStore from '../store/store'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

const store = useStore()
const isSaving = ref(false)

function resetStore() {
  store.reset()
}

async function save() {
  isSaving.value = true

  store
    .saveCollectionObject()
    .then(() => {
      TW.workbench.alert.create(
        'Collection object was successfully saved.',
        'notice'
      )
    })
    .finally(() => {
      isSaving.value = false
    })
}

function saveAndNew() {
  isSaving.value = true

  store
    .saveCollectionObject()
    .then(() => {
      resetStore()
      TW.workbench.alert.create(
        'Collection object was successfully saved.',
        'notice'
      )
    })
    .finally(() => {
      isSaving.value = false
    })
}
</script>

<style scoped>
.button-input {
  min-height: 28px;
}
</style>
