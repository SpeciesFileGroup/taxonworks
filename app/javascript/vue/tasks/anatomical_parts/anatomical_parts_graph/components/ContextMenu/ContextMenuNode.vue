<template>
  <div id="anatomical_part_graph_context_menu">
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
        v-if="inEditMode && ORIGINS.includes(nodeType)"
        :global-id="node.object_global_id"
        @create="() => emit('updateGraph')"
        @delete="() => emit('updateGraph')"
        @update="() => emit('updateGraph')"
        @change="() => emit('updateGraph')"
        @click.stop
      />
    </div>

    <div class="graph-context-menu-list-item">
      <VBtn
        v-if="inEditMode && ORIGINS.includes(nodeType)"
        color="primary"
        @click.stop="() => (showingCreate = true)"
      >
        Create child anatomical part
      </VBtn>
    </div>

    <div class="graph-context-menu-list-item">
      <VBtn
        v-if="inEditMode && nodeType == ANATOMICAL_PART"
        color="primary"
        @click.stop="() => (showingEdit = true)"
      >
        Edit anatomical part
      </VBtn>
    </div>

    <VModal
      v-if="showingCreate || showingEdit"
      :container-style="{
        width: '80vw',
        maxWidth: '1024px',
        maxHeight: '85vh',
        overflowY: 'auto'
      }"
      @close="() => {
        showingCreate = false
        showingEdit = false
      }"
    >
      <template #header>
        <h2>Create new anatomical part endpoint of <span v-html="node.name" /></h2>
      </template>

      <template #body>
        <AnatomicalParts
          :object-id="parseNodeId(nodeId).id"
          :object-type="nodeType"
          :modal-create="showingCreate"
          :modal-edit="showingEdit"
          @originRelationshipCreated="() => {
            emit('updateGraph')
            context.closeContextMenu()
          }"
          @click.stop
        />
      </template>
    </VModal>

  </div>
</template>

<script setup>
import { makeBrowseUrl } from '@/helpers'
import { computed, ref } from 'vue'
import { parseNodeId } from '../../utils'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/object/radial.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal'
import {
  ANATOMICAL_PART,
  COLLECTION_OBJECT,
  FIELD_OCCURRENCE,
  OTU
} from '@/constants'
import AnatomicalParts from '@/components/radials/object/components/origin_relationship/create/anatomical_parts/AnatomicalParts.vue'

const ORIGINS = [ANATOMICAL_PART, COLLECTION_OBJECT, FIELD_OCCURRENCE, OTU]

const props = defineProps({
  nodeId: { // node ids are of the form <nodeType>:<nodeId>
    type: String,
    required: true
  },

  node: {
    type: Object,
    default: () => ({})
  },

  inEditMode: {
    type: Boolean,
    default: true
  },

  context: {
    type: Object,
    required: true
  }
})

const showingCreate = ref(false)
const showingEdit = ref(false)

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