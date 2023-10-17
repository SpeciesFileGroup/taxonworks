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
  </div>
</template>

<script setup>
import LeafletMap from '@/components/georeferences/map.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { ref, computed } from 'vue'
import { useDraggable } from '@/compositions'

defineProps({
  geojson: {
    type: Array,
    default: () => []
  }
})

const floatPanel = ref(null)
const handler = ref(null)
const { style, styleHandler } = useDraggable({ target: floatPanel, handler })

const styleFloatmap = computed(() => ({
  left: style.value.left,
  top: style.value.top,
  transform: style.value.transform
}))
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
</style>
