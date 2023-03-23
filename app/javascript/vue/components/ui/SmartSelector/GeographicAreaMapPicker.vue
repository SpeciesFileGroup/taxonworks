<template>
  <div>
    <VSpinner v-if="isLoading" />
    <VMap
      class="margin-small-bottom"
      :geojson="geojson"
      height="300px"
      width="100%"
      :zoom="2"
      :fit-bounds="false"
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
    />
    <ul class="no_bullets">
      <li
        v-for="item in geographicAreas"
        :key="item.id"
        class="list__item"
      >
        <label>
          <input
            :name="`smart-geographic-${name}`"
            type="radio"
            :value="item.id"
            :checked="selectedItem && item.id === selectedItem.id"
            @click="() => emit('select', item)"
          />
          {{ item.name }}
        </label>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { GeographicArea } from 'routes/endpoints'
import VSpinner from 'components/spinner.vue'
import VMap from 'components/georeferences/map.vue'
import { useRandomUUID } from 'helpers/random.js'

const props = defineProps({
  modelValue: {
    type: Object,
    default: undefined
  },

  name: {
    type: String,
    default: useRandomUUID()
  }
})

const emit = defineEmits(['select', 'update:modelValue'])

const selectedItem = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const geojson = ref([])
const geographicAreas = ref([])
const isLoading = ref(false)

function addShape(shape) {
  const wkt = `POINT (${shape.geometry.coordinates.join(' ')})`

  geojson.value = [shape]
  loadGeopgraphicAreas(wkt)
}

function loadGeopgraphicAreas(wkt) {
  const payload = {
    containing_point: wkt
  }

  isLoading.value = true
  GeographicArea.where(payload)
    .then(({ body }) => {
      geographicAreas.value = body
    })
    .finally(() => {
      isLoading.value = false
    })
}
</script>
