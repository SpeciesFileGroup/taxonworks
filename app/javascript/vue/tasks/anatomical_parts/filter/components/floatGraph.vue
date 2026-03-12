<template>
  <div
    class="panel float-graph"
    ref="floatPanel"
    :style="styleFloatGraph"
  >
    <div class="float-graph-buttons gap-small">
      <div
        class="button btn-default btn btn-default-circle leaflet-map-button middle draggable-handle"
        circle
        ref="handler"
        :style="styleHandler"
      >
        <VIcon
          name="cursorMove"
          small
        />
      </div>
      <VBtn
        class="leaflet-map-button"
        circle
        @click="() => (isGraphExpanded = !isGraphExpanded)"
      >
        <VIcon
          :name="isGraphExpanded ? 'contract' : 'expand'"
          x-small
        />
      </VBtn>
      <VBtn
        v-if="showClose"
        circle
        class="close-button leaflet-map-button"
        @click="() => emit('close')"
      >
        <VIcon
          name="close"
          x-small
        />
      </VBtn>
    </div>

    <AnatomicalPartsGraph
      ref="graph"
      graph-width="100%"
      graph-height="100%"
      :container-classes="['full_width', 'full_height']"
      :show-node-quick-forms="false"
    />
  </div>
</template>

<script setup>
import VIcon from '@/components/ui/VIcon/index.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { ref, computed, onMounted, watch } from 'vue'
import { useDraggable } from '@/composables'
import AnatomicalPartsGraph from '../../anatomical_parts_graph/components/AnatomicalPartsGraph.vue'

const props = defineProps({
  loadParams: {
    type: Object,
    default: () => ({})
  },

  showClose: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['close'])

const graph = ref(null)

const floatPanel = ref(null)
const handler = ref(null)
const isGraphExpanded = ref(false)
const { style, styleHandler } = useDraggable({ target: floatPanel, handler })

const styleFloatGraph = computed(() =>
  isGraphExpanded.value
    ? {
        display: 'fixed',
        left: 0,
        top: 0,
        width: '100%',
        height: '100%',
        zIndex: 5000
      }
    : {
        left: style.value.left,
        top: style.value.top,
        width: '600px',
        height: '600px',
        transform: style.value.transform
      }
)

onMounted(() => {
  if (!!props.loadParams.anatomical_part_id) {
    graph.value.createGraph(props.loadParams)
  }
})

watch(
  () => props.loadParams.anatomical_part_id,
  (newId) => {
    if (newId) {
      graph.value.createGraph(props.loadParams)
    }
  }
)
</script>

<style scoped lang="scss">
.float-graph {
  position: fixed;
  width: 600px;
  height: 600px;
  bottom: 20px;
  right: 20px;
  z-index: 1000;
}

.float-graph-buttons {
  display: flex;
  position: absolute;
  top: 12px;
  right: 12px;
  z-index: 2000;
}
</style>
