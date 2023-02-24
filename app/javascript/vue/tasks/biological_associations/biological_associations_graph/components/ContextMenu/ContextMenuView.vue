<template>
  <div
    class="graph-context-menu-list-item"
    @click="
      () => {
        store.modal.node = true
        store.currentNodeType = OTU
      }
    "
  >
    Add OTU
  </div>
  <div
    class="graph-context-menu-list-item"
    @click="
      () => {
        store.modal.node = true
        store.currentNodeType = COLLECTION_OBJECT
      }
    "
  >
    Add Collection object
  </div>
</template>

<script setup>
import { useGraphStore } from '../../store/useGraphStore'
import { COLLECTION_OBJECT, OTU } from 'constants/index.js'

const store = useGraphStore()
</script>
