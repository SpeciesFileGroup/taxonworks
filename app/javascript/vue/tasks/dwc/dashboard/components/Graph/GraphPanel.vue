<template>
  <div class="panel content graph-panel">
    <graph-index :metadata="metadata"/>
    <graph-collection-object />
  </div>
</template>
<script setup>

import GraphIndex from './GraphIndex.vue'
import GraphCollectionObject from './GraphCollectionObjects.vue'

const props = defineProps({
  metadata: {
    type: Object,
    required: true
  }
})

</script>

<style>
  .graph-panel {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 1em;
    grid-column: 2 / 4;
  }
</style>
