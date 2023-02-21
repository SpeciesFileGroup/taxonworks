<template>
  <VModal>
    <template #header>
      <h3>Select a biological relationship</h3>
    </template>
    <template #body>
      <SmartSelector
        model="biological_relationships"
        @selected="
          ($event) => {
            store.createEdge({
              source: store.selectedNodes[0],
              target: store.selectedNodes[1],
              relationship: $event
            })
            emit('close')
          }
        "
      />
    </template>
  </VModal>
</template>

<script setup>
import SmartSelector from 'components/ui/SmartSelector'
import VModal from 'components/ui/Modal.vue'
import { useGraphStore } from '../store/useGraphStore'

const emit = defineEmits('close')
const store = useGraphStore()
</script>
