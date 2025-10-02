<template>
  <div class="graph-context-menu-list-header">Node</div>

  <div class="graph-context-menu-list-item">
    <a
      v-if="objectBrowseLink"
      class="word_break"
      :href="objectBrowseLink"
      target="_blank"
      >{{ node.name }}</a
    >
  </div>
</template>

<script setup>
import { makeBrowseUrl } from '@/helpers'
import { computed } from 'vue'
import { parseNodeId } from '../../utils'

const props = defineProps({
  nodeId: {
    type: String,
    required: true
  },

  node: {
    type: Object,
    default: () => ({})
  }
})

const objectBrowseLink = computed(() => {
  const { id, objectType } = parseNodeId(props.nodeId)
  return makeBrowseUrl({ id, type: objectType })
})

</script>