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
      fit-bounds
      draw-marker
      @layer:create="addShape"
      @mouseenter="() => enableDraw()"
      @mouseleave="() => disableDraw()"
    />
    <ul class="no_bullets">
      <li
        v-for="item in shapes"
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
    <hr class="divisor" />
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { GeographicArea } from '@/routes/endpoints'
import { randomUUID } from '@/helpers'
import VSpinner from '@/components/ui/VSpinner.vue'
import VMap from '@/components/ui/VMap/VMap.vue'

const props = defineProps({
  // shapes must have `shape`, `data_origin`, and `name` attributes
  shapeEndpoint: {
    type: Object,
    default: GeographicArea
  },
  name: {
    type: String,
    default: randomUUID()
  }
})

const emit = defineEmits(['select'])

const selectedItem = ref(null)
const mapRef = ref(null)
const geojson = computed(() => {
  const data = shapes.value
    .filter((g) => g.shape)
    .map((g) => JSON.parse(JSON.stringify(g.shape)))

  if (geoHover.value) {
    const current = data.find(
      (g) => g.properties.shape.id === geoHover.value.id
    )

    current.properties.style = { color: 'blue' }

    return [current]
  }

  return data
})

const shapes = ref([])
const isLoading = ref(false)
const geoHover = ref(null)

function addShape({ feature }) {
  const wkt = `POINT (${feature.geometry.coordinates.join(' ')})`

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
  props.shapeEndpoint
    .where(payload)
    .then(({ body }) => {
      shapes.value = body
      disableDraw()
    })
    .finally(() => {
      isLoading.value = false
    })
}
</script>
