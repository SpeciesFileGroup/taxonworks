<template>
  <div
    class="panel content"
    v-help.section.freshnessIndex>
    <graph-index :metadata="metadata"/>
  </div>
  <div
    class="panel content"
    v-help.section.freshnessVersions>
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
