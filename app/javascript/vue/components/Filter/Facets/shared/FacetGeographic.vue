<template>
  <FacetContainer>
    <h3>Spatial</h3>

    <VSwitch
      v-if="Object.values(TABS).length > 0"
      class="separate-bottom"
      v-model="view"
      :options="Object.values(TABS)"
    />

    <div v-if="view === TABS.Shape">
      <ShapeSelector
        :minimal="true"
        @selectShape="(shape) => addShape(shape)"
        class="vue-autocomplete"
      />

      <ul
        v-if="Object.values(GEOGRAPHIC_OPTIONS)"
        class="no_bullets"
      >
        <li
          v-for="(value, key) in GEOGRAPHIC_OPTIONS"
          :key="key"
        >
          <label>
            <input
              type="radio"
              :value="value"
              v-model="geoMode"
            />
            {{ key }}
          </label>
        </li>
      </ul>

      <div class="field separate-top">
        <ul class="no_bullets table-entrys-list">
          <li
            class="middle flex-separate list-complete-item"
            v-for="(shape, index) in shapes"
            :key="shape.id"
          >
            <span
              :class="{
                subtle:
                  params.geo_mode ===
                    GEOGRAPHIC_OPTIONS.Spatial && !shape.has_shape
              }"
              v-html="shape.name"
            />
            <VBtn
              circle
              color="primary"
              @click="removeShape(index)"
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

    <VMap
      v-else
      width="100%"
      height="300px"
      :geojson="mapGeoJson"
      draw-controls
      :draw-polyline="false"
      :draw-marker="false"
      :drag-mode="false"
      :cut-polygon="false"
      :draw-circle-marker="false"
      :tiles-selection="false"
      :edit-mode="false"
      :zoom="1"
      @geojson="(geojson) => (mapGeoJson = geojson)"
      @geo-json-layer-created="addShapeFromMap"
    />
    <RadialFilterAttribute
      :parameters="{ shape_id: params.geo_shape_id }"
    />
  </FacetContainer>
</template>

<script setup>
import ShapeSelector from '@/components/ui/SmartSelector/ShapeSelector.vue'
import VSwitch from '@/components/ui/VSwitch'
import VMap from '@/components/georeferences/map'
import RadialFilterAttribute from '@/components/radials/linker/RadialFilterAttribute.vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { GeographicArea, Gazetteer } from '@/routes/endpoints'
import { ref, watch, onBeforeMount } from 'vue'

const props = defineProps({
  inputId: {
    type: String,
    default: undefined
  },

  noExact: {
    type: Boolean,
    default: false
  },

  // Note noExact implies noDescendants
  noDescendants: {
    type: Boolean,
    default: false
  }
})

let TABS // fib
let GEOGRAPHIC_OPTIONS // fib

if (props.noDescendants && props.noExact) {
  TABS = {}
  GEOGRAPHIC_OPTIONS = {}
} else if (props.noDescendants) { // && Exact
  TABS = {
    Shape: 'shape',
    Map: 'map'
  }
  GEOGRAPHIC_OPTIONS = {
    Spatial: true,
    Exact: undefined
  }
} else { // Descendants and Exact
  TABS = {
    Shape: 'shape',
    Map: 'map'
  }
  GEOGRAPHIC_OPTIONS = {
    Spatial: true,
    Descendants: false,
    Exact: undefined
  }
}

// We set shape_id: [], shape_type: [], radius, geo_json
const params = defineModel( {type: Object, required: true })

const shapes = ref([])
const geoMode = ref(GEOGRAPHIC_OPTIONS.Spatial)
const mapGeoJson = ref([])
const view = ref(TABS.Shape)

watch(geoMode, (newVal) => {
  params.value.geo_mode =
    shapes.value.length ? newVal : undefined
})

watch(
  mapGeoJson,
  (newVal) => {
    if (newVal.length) {
      const shape = newVal[0]

      params.value.geo_shape_type = []
      params.value.geo_shape_id = []

      if (shape.properties?.radius) {
        params.value.radius = shape.properties.radius
        params.value.geo_json = JSON.stringify({
          type: 'Point',
          coordinates: shape.geometry.coordinates
        })
      } else {
        params.value.geo_json = JSON.stringify({
          type: 'MultiPolygon',
          coordinates: newVal.map((feature) => feature.geometry.coordinates)
        })
        params.value.radius = undefined
      }
    } else {
      params.value.geo_json = []
    }
  },
  { deep: true }
)

watch(params, (newVal) => {
  if (!newVal?.length) {
    shapes.value = []
  }
})

watch(
  () => params.value.geo_json,
  (newVal, oldVal) => {
    if (!newVal?.length && oldVal?.length) {
      mapGeoJson.value = []
    }
  },
  { deep: true }
)

watch(
  [shapes, geoMode],
  () => {
    // TODO: revisit, simplify
    if (geoMode.value === GEOGRAPHIC_OPTIONS.Spatial) {
      params.value.geo_shape_id =
        shapes.value
          .filter((item) => item.has_shape)
          .map((item) => item.id)

      params.value.geo_shape_type =
        shapes.value
          .filter((item) => item.has_shape)
          .map((item) => item.shapeType)
    } else {
      params.value.geo_shape_id =
        shapes.value
          .map((item) => item.id)

      params.value.geo_shape_type =
        shapes.value
          .map((item) => item.shapeType)
    }
  },
  { deep: true }
)

watch(
  () => params.value.geo_shape_id,
  (newVal, oldVal) => {
    if (!newVal?.length && oldVal?.length) {
      shapes.value = []
    }

    params.value.geo_mode =
      newVal?.length ? geoMode.value : undefined
  },
  { deep: true }
)

function addShapeFromMap(shape) {
  mapGeoJson.value = [shape]
}

function removeShape(index) {
  shapes.value.splice(index, 1)
}

function addShapeFromId(id, type) {
  if (type == 'GeographicArea') {
    GeographicArea.find(id)
      .then(({ body }) => {
        body.shapeType = 'GeographicArea'
        addShape(body)
      })
      .catch(() => {})
  } else {
    Gazetteer.find(id)
      .then(({ body }) => {
        body.shapeType = 'Gazetteer'
        addShape(body)
      })
      .catch(() => {})
  }
}

function addShape(shape) {
  params.value.geo_json = undefined
  params.value.radius = undefined
  shapes.value.push(shape)
}

function convertGeoJSONParam(geojsonParam) {
  const geojson = JSON.parse(geojsonParam)

  return {
    type: 'Feature',
    geometry: {
      coordinates:
        geojson.type === 'Point' ? geojson.coordinates : geojson.coordinates[0],
      type: geojson.type === 'Point' ? 'Point' : 'Polygon'
    },
    properties: {
      radius: geojsonParam?.radius
    }
  }
}

onBeforeMount(() => {
  try {
    if (params.value.geo_shape_id?.length > 0) {
      const shapeIds = [params.value.geo_shape_id].flat()
      const shapeTypes = [params.value.geo_shape_type].flat()

      let i = 0
      shapeIds.forEach((id) => {
        addShapeFromId(id, shapeTypes[i])
        i = i + 1
      })
      geoMode.value = params.value.geo_mode
    } else if (params.value.geo_json) {
      addShapeFromMap(convertGeoJSONParam(params.value.geo_json))
      view.value = TABS.Map
    }
  } catch {}
})
</script>
