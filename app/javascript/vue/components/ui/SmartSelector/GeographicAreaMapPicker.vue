<template>
  <div class="margin-small-bottom">
    <VSpinner v-if="isLoading" />
    <VMap
      ref="mapRef"
      class="margin-small-bottom"
      :geojson="geojson"
      height="300px"
      width="100%"
      :zoom="2"
      :fit-bounds="true"
      draw-controls
      :draw-circle="false"
      :draw-polyline="false"
      :draw-polygon="false"
      :draw-line="false"
      :draw-rectangle="false"
      :draw-circle-marker="false"
      :removal-mode="false"
      :cut-polygon="false"
      :edit-mode="false"
      :drag-mode="false"
      @geo-json-layer-created="addShape"
      @mouseenter="() => enableDraw()"
      @mouseleave="() => disableDraw()"
    />
    <ul class="no_bullets">
      <li
        v-for="item in geographicAreas"
        :key="item.id"
        class="list__item"
      >
        <label
          @mouseover="() => (geoHover = item)"
          @mouseout="() => (geoHover = null)"
        >
          <input
            :name="`smart-geographic-${name}`"
            type="radio"
            :value="item.id"
            :checked="selectedItem && item.id === selectedItem.id"
            @click="() => emit('select', item)"
          />
          {{ item.name }} ({{ item.data_origin }})
        </label>
      </li>
    </ul>
    <hr />
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { GeographicArea } from '@/routes/endpoints'
import VSpinner from '@/components/ui/VSpinner.vue'
import VMap from '@/components/georeferences/map.vue'
import { randomUUID } from '@/helpers'

const props = defineProps({
  modelValue: {
    type: Object,
    default: undefined
  },

  name: {
    type: String,
    default: randomUUID()
  }
})

const emit = defineEmits(['select', 'update:modelValue'])

const mapRef = ref(null)
const geojson = computed(() => {
  const data = geographicAreas.value
    .filter((g) => g.shape)
    .map((g) => JSON.parse(JSON.stringify(g.shape)))

  if (geoHover.value) {
    const current = data.find(
      (g) => g.properties.geographic_area.id === geoHover.value.id
    )

    current.properties.style = { color: 'blue' }

    return [current]
  }

  return data
})

const selectedItem = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const geographicAreas = ref([])
const isLoading = ref(false)
const geoHover = ref(null)

function addShape(shape) {
  const wkt = `POINT (${shape.geometry.coordinates.join(' ')})`

  loadGeopgraphicAreas(wkt)
}

function enableDraw() {
  mapRef.value.getMapObject().pm.enableDraw('Marker')
}

function disableDraw() {
  mapRef.value.getMapObject().pm.disableDraw()
}

function loadGeopgraphicAreas(wkt) {
  const payload = {
    containing_point: wkt,
    embed: ['shape']
  }

  isLoading.value = true
  GeographicArea.where(payload)
    .then(({ body }) => {
      geographicAreas.value = body
      disableDraw()
    })
    .finally(() => {
      isLoading.value = false
    })
}
</script>
