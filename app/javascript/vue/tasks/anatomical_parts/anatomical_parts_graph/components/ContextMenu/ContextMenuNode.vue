<template>
  <div class="graph-context-menu-list-header">Node</div>

  <div class="horizontal-left-content gap-small graph-context-menu-list-item">
    <a
      v-if="objectBrowseLink"
      class="word_break"
      :href="objectBrowseLink"
      target="_blank"
      @click.stop
      >{{ node.name }}</a
    >
    <RadialAnnotator
      :global-id="node.object_global_id"
      @click.stop
    />
  </div>
</template>

<script setup>
import { makeBrowseUrl } from '@/helpers'
import { computed } from 'vue'
import { parseNodeId } from '../../utils'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'

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