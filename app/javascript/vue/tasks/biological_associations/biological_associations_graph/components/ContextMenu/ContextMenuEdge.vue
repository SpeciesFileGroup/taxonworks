<template>
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
        :color="!!edges[edgeId].id ? 'destroy' : 'primary'"
        @click="
          () => {
            emit('remove:edge', edgeId)
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
    Add citation
  </div>
</template>

<script setup>
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'

defineProps({
  selectedEdgeIds: {
    type: String,
    required: true
  },

  edges: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['remove:edge', 'reverse:edge', 'cite:edge'])
</script>
