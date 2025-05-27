<template>
  <div class="horizontal-left-content gap-small">
    <VBtn
      color="create"
      medium
      :disabled="!!store.collectionObject.id"
      @click="store.saveCollectionObject()"
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
import useStore from '../store/store'
import VBtn from '@/components/ui/VBtn/index.vue'

const store = useStore()

function resetStore() {
  store.reset()
}

function saveAndNew() {
  store.saveCollectionObject().then(() => {
    resetStore()
  })
}
</script>

<style scoped>
.button-input {
  min-height: 28px;
}
</style>
