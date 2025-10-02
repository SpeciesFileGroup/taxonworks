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
    <RadialObject
      v-if="showQuickForms && ORIGINS.includes(nodeType)"
      :global-id="node.object_global_id"
      @create="() => emit('updateGraph')"
      @delete="() => emit('updateGraph')"
      @update="() => emit('updateGraph')"
      @change="() => emit('updateGraph')"
      @click.stop
    />
  </div>
</template>

<script setup>
import { makeBrowseUrl } from '@/helpers'
import { computed } from 'vue'
import { parseNodeId } from '../../utils'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/object/radial.vue'
import {
  ANATOMICAL_PART,
  COLLECTION_OBJECT,
  FIELD_OCCURRENCE,
  OTU
} from '@/constants'

const ORIGINS = [ANATOMICAL_PART, COLLECTION_OBJECT, FIELD_OCCURRENCE, OTU]

const props = defineProps({
  nodeId: {
    type: String,
    required: true
  },

  node: {
    type: Object,
    default: () => ({})
  },

  showQuickForms: {
    type: Boolean,
    default: true
  }
})

const emit = defineEmits(['updateGraph'])

const objectBrowseLink = computed(() => {
  const { id, objectType } = parseNodeId(props.nodeId)
  return makeBrowseUrl({ id, type: objectType })
})

const nodeType = computed(() => {
  const { id, objectType } = parseNodeId(props.nodeId)
  return objectType
})

</script>