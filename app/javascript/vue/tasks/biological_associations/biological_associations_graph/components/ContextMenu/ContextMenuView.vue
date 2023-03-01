<template>
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
</template>

<script setup>
import { COLLECTION_OBJECT, OTU } from 'constants/index.js'

const emit = defineEmits(['add:node'])
</script>
