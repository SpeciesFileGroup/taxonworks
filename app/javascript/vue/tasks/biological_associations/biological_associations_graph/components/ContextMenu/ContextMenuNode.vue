<template>
  <div class="graph-context-menu-list-header">CO/FO/OTU</div>
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
        circle
        color="primary"
        @click="() => emit('remove:node', { nodeId, destroy: false })"
      >
        <VIcon
          x-small
          name="trash"
        />
      </VBtn>
      <VBtn
        circle
        v-if="isSaved"
        color="destroy"
        @click="() => emit('remove:node', { nodeId, destroy: true })"
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
import { OTU, COLLECTION_OBJECT, FIELD_OCCURRENCE } from '@/constants'
import { RouteNames } from '@/routes/routes'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

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

const browseTask = {
  [OTU]: (id) => `${RouteNames.BrowseOtu}?otu_id=${id}`,
  [COLLECTION_OBJECT]: (id) =>
    `${RouteNames.BrowseCollectionObject}?collection_object_id=${id}`,
  [FIELD_OCCURRENCE]: (id) =>
    `${RouteNames.BrowseFieldOccurrence}?field_occurrence_id=${id}`
}

const objectBrowseLink = computed(() => {
  const { id, objectType } = parseNodeId(props.nodeId)
  const makeTaskUrl = browseTask[objectType]

  return makeTaskUrl ? makeTaskUrl(id) : null
})
</script>
