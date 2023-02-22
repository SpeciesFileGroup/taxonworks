<template>
  <VNavbar>
    <div class="gap-xsmall">
      <VBtn
        color="primary"
        medium
        :disabled="store.selectedNodes.length !== 2"
        @click="() => (store.modal.edge = true)"
      >
        Create relation
      </VBtn>
      <VBtn
        color="create"
        medium
        :disabled="!Object.keys(store.edges).length"
        @click="() => store.createBiologicalAssociation()"
      >
        Save biological associations
      </VBtn>
    </div>
  </VNavbar>
</template>

<script setup>
import VNavbar from 'components/layout/NavBar'
import VBtn from 'components/ui/VBtn/index.vue'
import { useGraphStore } from '../store/useGraphStore.js'

const store = useGraphStore()
</script>
