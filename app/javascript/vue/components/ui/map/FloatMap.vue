<template>
  <div
    class="panel float-map"
    ref="floatPanel"
    :style="styleFloatmap"
  >
    <VMap
      class="map"
      :geojson="geojson"
      resize
      width="100%"
      height="100%"
      :zoom-bounds="15"
    />
    <div class="float-map-buttons gap-small">
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
        @click="() => (isMapExpanded = !isMapExpanded)"
      >
        <VIcon
          :name="isMapExpanded ? 'contract' : 'expand'"
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
  </div>
</template>

<script setup>
import VMap from '@/components/ui/VMap/VMap.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { ref, computed } from 'vue'
import { useDraggable } from '@/composables'

defineProps({
  geojson: {
    type: Array,
    default: () => []
  },

  showClose: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['close'])

const floatPanel = ref(null)
const handler = ref(null)
const isMapExpanded = ref(false)
const { style, styleHandler } = useDraggable({ target: floatPanel, handler })

const styleFloatmap = computed(() =>
  isMapExpanded.value
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
        transform: style.value.transform
      }
)
</script>

<style scoped lang="scss">
.float-map {
  position: fixed;
  width: 600px;
  height: 400px;
  bottom: 20px;
  right: 20px;
  z-index: 1000;
}

.map {
  border-radius: 0.3rem;
}

.float-map-buttons {
  display: flex;
  position: absolute;
  top: 12px;
  right: 12px;
  z-index: 2000;
}
</style>
