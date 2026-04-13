<template>
  <div class="graph-context-menu-list-header">Edge</div>

  <div class="horizontal-left-content gap-small graph-context-menu-list-item">
    <a
      class="word_break"
      :href="`/origin_relationships/${edges[selectedEdgeIds[0]].id}`"
      target="_blank"
      @click.stop
    >
      Origin relationship
    </a>

    <RadialAnnotator
      :global-id="edges[selectedEdgeIds[0]].object_global_id"
      @click.stop
    />
  </div>
</template>

<script setup>
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'

defineProps({
  selectedEdgeIds: { // Always only one edge??
    type: Array,
    default: () => []
  },

  edges: {
    type: Object,
    default: () => ({})
  }
})

</script>
