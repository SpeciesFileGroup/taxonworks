<template>
  <div
    class="panel float-map"
    ref="floatPanel"
    :style="styleFloatmap"
  >
    <leaflet-map
      class="map"
      :geojson="geojson"
      resize
      width="100%"
      height="100%"
      :zoom-bounds="15"
    />
    <div
      class="draggable-handle panel padding-small"
      ref="handler"
      :style="styleHandler"
    >
      <VIcon
        name="cursorMove"
        small
      />
    </div>
    <div
      class="expand-button panel padding-small"
      @click="() => (isMapExpanded = !isMapExpanded)"
    >
      <VIcon
        :name="isMapExpanded ? 'contract' : 'expand'"
        small
      />
    </div>
  </div>
</template>

<script setup>
import LeafletMap from '@/components/georeferences/map.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { ref, computed } from 'vue'
import { useDraggable } from '@/composables'

defineProps({
  geojson: {
    type: Array,
    default: () => []
  }
})

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

.draggable-handle {
  position: absolute;
  top: 12px;
  right: 12px;
  z-index: 2000;
}

.expand-button {
  position: absolute;
  top: 12px;
  right: 48px;
  z-index: 2000;
}
</style>
