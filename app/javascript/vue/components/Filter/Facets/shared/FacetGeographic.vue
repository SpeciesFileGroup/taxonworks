<template>
  <FacetContainer>
    <h3>Geographic area</h3>
    <switch-component
      class="separate-bottom"
      v-model="view"
      :options="Object.values(TABS)"
    />
    <div v-if="view === 'area'">
      <div class="field">
        <autocomplete
          :input-id="inputId"
          url="/geographic_areas/autocomplete"
          label="label_html"
          clear-after
          placeholder="Search a geographic area"
          param="term"
          @get-item="addGeoArea($event.id)"
        />
      </div>

      <ul class="no_bullets">
        <li
          v-for="(value, key) in GEOGRAPHIC_OPTIONS"
          :key="key"
        >
          <label>
            <input
              type="radio"
              :value="value"
              v-model="geographic.geographic_area_mode"
            >
            {{ key }}
          </label>
        </li>
      </ul>

      <div class="field separate-top">
        <ul class="no_bullets table-entrys-list">
          <li
            class="middle flex-separate list-complete-item"
            v-for="(geoArea, index) in geographicAreas"
            :key="geoArea.id"
          >
            <span
              :class="{ subtle: geographic.geographic_area_mode === GEOGRAPHIC_OPTIONS.Spatial && !geoArea.has_shape }"
              v-html="geoArea.name"
            />
            <VBtn
              circle
              color="primary"
              @click="removeGeoArea(index)"
            >
              <VIcon
                x-small
                name="trash"
              />
            </VBtn>
          </li>
        </ul>
      </div>
    </div>
    <div v-else>
      <georeference-map
        width="100%"
        height="300px"
        :geojson="geojson"
        draw-controls
        :draw-polyline="false"
        :draw-marker="false"
        :drag-mode="false"
        :cut-polygon="false"
        :draw-circle-marker="false"
        :tiles-selection="false"
        :edit-mode="false"
        :zoom="1"
        @geojson="geojson = $event"
        @geo-json-layer-created="addShape"
      />
    </div>
    <RadialFilterAttribute :parameters="{ geographic_area_id: geographic.geographic_area_id }" />
  </FacetContainer>
</template>

<script setup>

import SwitchComponent from 'components/switch'
import Autocomplete from 'components/ui/Autocomplete'
import GeoreferenceMap from 'components/georeferences/map'
import RadialFilterAttribute from 'components/radials/linker/RadialFilterAttribute.vue'
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import { GeographicArea } from 'routes/endpoints'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { computed, ref, watch, onBeforeMount } from 'vue'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'

const TABS = {
  Area: 'area',
  Map: 'map'
}

const GEOGRAPHIC_OPTIONS = {
  Spatial: true,
  Descendants: false,
  Exact: undefined
}

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  },
  inputId: {
    type: String,
    default: undefined
  }
})

const emit = defineEmits(['update:modelValue'])

const geographic = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})
const geographicAreas = ref([])
const geojson = ref([])
const view = ref(TABS.Area)

watch(
  geojson,
  newVal => {
    if (newVal.length) {
      const shape = newVal[0]

      geographic.value.geographic_area_id = []
      if (shape.properties?.radius) {
        geographic.value.radius = shape.properties.radius
        geographic.value.geo_json = JSON.stringify({ type: 'Point', coordinates: shape.geometry.coordinates })
      } else {
        geographic.value.geo_json = JSON.stringify({ type: 'MultiPolygon', coordinates: newVal.map(feature => feature.geometry.coordinates) })
        geographic.value.radius = undefined
      }
    } else {
      geographic.value.geo_json = []
    }
  },
  { deep: true }
)

const addShape = (shape) => {
  geojson.value = [shape]
}

const removeGeoArea = (index) => {
  geographicAreas.value.splice(index, 1)
}

const addGeoArea = id => {
  GeographicArea.find(id).then(response => {
    geographic.value.geo_json = undefined
    geographic.value.radius = undefined
    geographicAreas.value.push(response.body)
  })
}

const convertGeoJSONParam = (urlParams) => {
  const geojson = JSON.parse(urlParams.geo_json)

  return {
    type: 'Feature',
    geometry: {
      coordinates: geojson.type === 'Point' ? geojson.coordinates : geojson.coordinates[0],
      type: geojson.type === 'Point' ? 'Point' : 'Polygon'
    },
    properties: {
      radius: geojson?.radius
    }
  }
}

watch(
  () => geographic.value.geo_json,
  (newVal, oldVal) => {
    if (!newVal?.length && oldVal?.length) {
      geojson.value = []
    }
  },
  { deep: true }
)

watch(
  [
    geographicAreas,
    () => geographic.value.geographic_area_mode
  ],
  () => {
    geographic.value.geographic_area_id = geographic.value.geographic_area_mode === GEOGRAPHIC_OPTIONS.Spatial
      ? geographicAreas.value.filter(item => item.has_shape).map(item => item.id)
      : geographicAreas.value.map(item => item.id)
  },
  { deep: true }
)

watch(
  () => geographic.value.geographic_area_id,
  (newVal, oldVal) => {
    if (!newVal?.length && oldVal?.length) {
      geographicAreas.value = []
    }
  },
  { deep: true }
)

onBeforeMount(() => {
  const urlParams = URLParamsToJSON(location.href)

  if (Object.keys(urlParams).length) {
    if (urlParams.geographic_area_id) {
      urlParams.geographic_area_id.forEach(id => {
        addGeoArea(id)
      })
    }
    if (urlParams.geo_json) {
      addShape(convertGeoJSONParam(urlParams))
    }
    geographic.value.geographic_area_mode = urlParams.geographic_area_mode
  }
})
</script>
<style scoped>
  :deep(.vue-autocomplete-input) {
    width: 100%
  }
</style>
