<template>
  <div class="graph-context-menu-list-header">
    {{ title }} ({{ count }} BAs)
  </div>
  <div
    class="graph-context-menu-list-item"
    @click="
      () => {
        emit('add:node', { type: OTU })
      }
    "
  >
    Add OTU
  </div>
  <div
    class="graph-context-menu-list-item"
    @click="
      () => {
        emit('add:node', { type: COLLECTION_OBJECT })
      }
    "
  >
    Add Collection object
  </div>
  <div
    class="graph-context-menu-list-item"
    @click="() => emit('cite:graph')"
  >
    Add Citation
  </div>
</template>

<script setup>
import { COLLECTION_OBJECT, OTU } from 'constants/index.js'

const emit = defineEmits(['add:node', 'cite:graph'])

defineProps({
  title: {
    type: String,
    default: 'Unnamed graph'
  },

  count: {
    type: Number,
    default: 0
  }
})
</script>
