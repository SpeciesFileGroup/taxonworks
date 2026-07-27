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
        icon
        variant="tonal"
        color="primary"
        @click="
          () => {
            emit('remove:edge', { edgeId, destroy: false })
          }
        "
      >
        <IconTrash class="w-4 h-4" />
      </VBtn>
      <VBtn
        v-if="!!edges[edgeId].id"
        icon
        variant="tonal"
        color="destroy"
        @click="
          () => {
            emit('remove:edge', { edgeId, destroy: true })
          }
        "
      >
        <IconTrash class="w-4 h-4" />
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
import IconTrash from '@/components/Icon/IconTrash.vue'

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
