<template>
  <div class="graph-context-menu-list-header">CO/FO/OTU/AP</div>
  <div class="flex-separate middle gap-small graph-context-menu-list-item">
    <a
      v-if="objectBrowseLink"
      class="word_break"
      :href="objectBrowseLink"
      >{{ node.name }}</a
    >
    <span v-else>{{ node.name }}</span>
    <div class="horizontal-right-content gap-xsmall">
      <VBtn
        icon
        variant="tonal"
        color="primary"
        @click="() => emit('remove:node', { nodeId, destroy: false })"
      >
        <IconTrash class="w-4 h-4" />
      </VBtn>
      <VBtn
        icon
        variant="tonal"
        v-if="isSaved"
        color="destroy"
        @click="() => emit('remove:node', { nodeId, destroy: true })"
      >
        <IconTrash class="w-4 h-4" />
      </VBtn>
    </div>
  </div>
  <div
    class="graph-context-menu-list-item"
    @click="() => emit('open:related')"
  >
    Add related
  </div>
  <div
    v-if="createButton"
    class="graph-context-menu-list-item"
    @click="() => emit('add:edge')"
  >
    Create relation
  </div>
  <div
    v-if="hasRelationship"
    class="graph-context-menu-list-item"
    @click="() => emit('cite:edge')"
  >
    Citations ({{ citations }})
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { parseNodeId } from '../../utils'
import { makeBrowseUrl } from '@/helpers'
import VBtn from '@/components/ui/VBtn/index.vue'
import IconTrash from '@/components/Icon/IconTrash.vue'

const props = defineProps({
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

  hasRelationship: {
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

const emit = defineEmits([
  'remove:node',
  'add:edge',
  'cite:edge',
  'open:related'
])

const objectBrowseLink = computed(() => {
  const { id, objectType } = parseNodeId(props.nodeId)
  return makeBrowseUrl({ id, type: objectType })
})
</script>
