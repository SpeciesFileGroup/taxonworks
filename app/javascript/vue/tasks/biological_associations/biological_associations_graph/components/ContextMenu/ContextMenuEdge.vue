<template>
  <div class="graph-context-menu-list-header">Biological associations</div>
  <div
    v-for="edgeId in selectedEdgeIds"
    :key="edgeId"
    class="flex-separate middle gap-small graph-context-menu-list-item"
  >
    {{ edges[edgeId].label }}
    <div class="horizontal-right-content gap-xsmall">
      <VBtn
        color="primary"
        class="circle-button"
        @click="
          () => {
            emit('reverse:edge', edgeId)
          }
        "
      >
        <VIcon
          name="swap"
          x-small
        />
      </VBtn>
      <VBtn
        circle
        color="primary"
        @click="
          () => {
            emit('remove:edge', { edgeId, destroy: false })
          }
        "
      >
        <VIcon
          x-small
          name="trash"
        />
      </VBtn>
      <VBtn
        v-if="!!edges[edgeId].id"
        circle
        color="destroy"
        @click="
          () => {
            emit('remove:edge', { edgeId, destroy: true })
          }
        "
      >
        <VIcon
          x-small
          name="trash"
        />
      </VBtn>
    </div>
  </div>
  <div
    class="graph-context-menu-list-item"
    @click="() => emit('cite:edge', selectedEdgeIds)"
  >
    Citations ({{ citations }})
  </div>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

defineProps({
  selectedEdgeIds: {
    type: Array,
    default: () => []
  },

  edges: {
    type: Object,
    default: () => ({})
  },

  citations: {
    type: Number,
    default: 0
  }
})

const emit = defineEmits(['remove:edge', 'reverse:edge', 'cite:edge'])
</script>
