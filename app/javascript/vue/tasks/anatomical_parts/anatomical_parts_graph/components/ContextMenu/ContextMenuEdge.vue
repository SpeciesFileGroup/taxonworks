<template>
  <div class="graph-context-menu-list-header">Edge</div>

  <div class="graph-context-menu-list-item">
    <a
      class="word_break"
      :href="`/origin_relationships/${edges[selectedEdgeIds[0]].id}`"
      target="_blank"
      >Origin relationship</a
    >
  </div>
</template>

<script setup>
defineProps({
  selectedEdgeIds: {
    type: Array,
    default: () => []
  },

  edges: {
    type: Object,
    default: () => ({})
  }
})

</script>
