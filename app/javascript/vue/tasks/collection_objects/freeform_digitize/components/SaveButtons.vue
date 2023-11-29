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
      @click="saveAndNew"
    >
      Save and new
    </VBtn>

    <VBtn
      color="primary"
      medium
      @click="resetStore"
    >
      New
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
