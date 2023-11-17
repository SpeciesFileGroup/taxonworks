<template>
  <div class="panel content">
    <h2>Summary</h2>
    <div class="horizontal-left-content gap-small">
      <VBtn
        color="create"
        medium
        @click="store.saveCollectionObject()"
      >
        Save
      </VBtn>

      <VBtn
        color="create"
        medium
        @click="resetCO"
      >
        Save and new
      </VBtn>
    </div>
  </div>
</template>

<script setup>
import useStore from '../store/store'
import VBtn from '@/components/ui/VBtn/index.vue'

const store = useStore()

function resetCO() {
  store.$reset()
}
</script>

<style scoped>
.button-input {
  min-height: 28px;
}
</style>
