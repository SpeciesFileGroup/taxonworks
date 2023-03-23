<template>
  <div class="graph-context-menu-list-header">CO/OTU</div>
  <div class="flex-separate middle gap-small graph-context-menu-list-item">
    <span>{{ node.name }}</span>
    <VBtn
      circle
      :color="isSaved ? 'destroy' : 'primary'"
      @click="() => emit('remove:node', nodeId)"
    >
      <VIcon
        x-small
        name="trash"
      />
    </VBtn>
  </div>
  <div
    v-if="createButton"
    class="graph-context-menu-list-item"
    @click="() => emit('add:edge')"
  >
    Create relation
  </div>
  <div
    v-if="isSaved"
    class="graph-context-menu-list-item"
    @click="() => emit('cite:edge')"
  >
    Citations ({{ citations }})
  </div>
</template>

<script setup>
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'

defineProps({
  nodeId: {
    type: String,
    required: true
  },

  node: {
    type: Object,
    default: () => ({})
  },

  isSaved: {
    type: Boolean,
    default: false
  },

  citations: {
    type: Number,
    default: 0
  },

  createButton: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['remove:node', 'add:edge', 'cite:edge'])
</script>
