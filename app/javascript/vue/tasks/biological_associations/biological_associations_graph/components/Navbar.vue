<template>
  <VNavbar>
    <div class="flex-separate">
      <VAutocomplete
        url="/biological_associations_graphs/autocomplete"
        param="term"
        label="label_html"
        clear-after
        placeholder="Search a graph..."
        @get-item="({ id }) => store.loadGraph(id)"
      />
      <div class="horizontal-left-content gap-small">
        <UnsavedIndicator v-if="store.isUnsaved" />
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
          @click="() => store.saveBiologicalAssociations()"
        >
          Save
        </VBtn>
      </div>
    </div>
  </VNavbar>
</template>

<script setup>
import VNavbar from '@/components/layout/NavBar'
import VBtn from '@/components/ui/VBtn/index.vue'
import UnsavedIndicator from '@/components/ui/UnsavedIndicator/UnsavedIndicator.vue'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import { useGraphStore } from '../store/useGraphStore.js'

const store = useGraphStore()
</script>
