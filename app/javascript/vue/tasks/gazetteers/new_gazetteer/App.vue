<template>
  <VSpinner v-if="isLoading" />
  <NavBar
    :gz="gz"
    :save-disabled="saveDisabled"
    @clone-gz="() => cloneGz()"
    @save-gz="() => saveGz()"
    @reset-gz="() => reset()"
  />

  <div class="field label-above">
    <label>Name</label>
    <input
      type="text"
      class="normal-input name-input"
      v-model="gz.name"
    />
  </div>

  <div class="field label-above">
    <label>ISO 3166 A2 country code</label>
    <input
      type="text"
      class="input-xsmall-width"
      v-model="gz.iso_3166_a2"
    />
  </div>

  <div class="field label-above">
    <label>ISO 3166 A3 country code</label>
    <input
      type="text"
      class="input-xsmall-width"
      v-model="gz.iso_3166_a3"
    />
  </div>

  <OtherInputs
    :inputs-disabled="shapeEditingDisabled"
    @new-shape="(data, type) => addToShapes(data, type)"
  />

  <Leaflet
    :shapes="leafletShapes"
    @shapes-updated="(shape) => addToShapes(shape, GZ_LEAFLET)"
    :editing-disabled="shapeEditingDisabled"
  />

  <Preview
    v-model="previewing"
    :preview-disabled="previewDisabled"
  />

  <OtherInputs
    :inputs-disabled="shapeEditingDisabled"
    @new-shape="(data, type) => addToShapes(data, type)"
  />

  <UnionInput
    :inputs-disabled="shapeEditingDisabled"
    @new-shape="(data, type) => addToShapes(data, type)"
  />

  <DisplayList
    class="geolist"
    :list="shapes"
    @delete="(shape) => removeFromShapes(shape)"
    :editing-disabled="shapeEditingDisabled"
  />
</template>

<script setup>
import DisplayList from './components/DisplayList.vue'
import Leaflet from './components/Leaflet.vue'
import NavBar from './components/NavBar.vue'
import OtherInputs from './components/OtherInputs.vue'
import Preview from './components/Preview.vue'
import UnionInput from './components/UnionInput.vue'
import SetParam from '@/helpers/setParam'
import VSpinner from '@/components/ui/VSpinner.vue'
import { Gazetteer } from '@/routes/endpoints'
import { computed, ref, watch } from 'vue'
import { randomUUID } from '@/helpers'
import { RouteNames } from '@/routes/routes'
import { removeFromArray } from '@/helpers/arrays'
import { URLParamsToJSON } from '@/helpers/url/parse'
import { usePopstateListener } from '@/composables'
import {
  GZ_POINT,
  GZ_WKT,
  GZ_LEAFLET,
  GZ_UNION_GA,
  GZ_UNION_GZ,
  GZ_DATABASE
} from '@/constants/index.js'

const shapes = ref([])
const previewing = ref(false)
const previewShape = ref(null)
const gz = ref({})
const isLoading = ref(false)

const leafletShapes = computed(() => {
  if (previewing.value && previewShape.value) {
    return [previewShape.value.shape]
  } else {
    return shapes.value.map((item) => item.shape)
  }
})

const saveDisabled = computed(() => {
  const numShapes = shapes.value.length
  if (!(gz.value.name) || numShapes == 0) {
    return true
  }

  if (numShapes > 1) {
    return false
  }

  // We're not allowing save of a single GA or GZ (i.e. cloning) - use alternate
  // names for that (though this restriction is easily circumvented by, e.g.,
  // selecting a ga/gz and then adding a point that's contained by it)
  let gaCount = 0
  let gzCount = 0

  shapes.value.forEach((s) => {
    switch(s.type) {
      case GZ_UNION_GA:
        gaCount += 1
        break
      case GZ_UNION_GZ:
        gzCount += 1
        break
    }
  })

  const oneSoleGA = numShapes == 1 && gaCount == 1
  const oneSoleGZ = numShapes == 1 && gzCount == 1

  return  oneSoleGA || oneSoleGZ
})

const shapeEditingDisabled = computed(() =>{
  return previewing.value || !!gz.value.id
})

const previewDisabled = computed(() => {
  return !!gz.value.id || shapes.value.length == 0
})

watch(
  previewing,
  (newVal) => {
    if (newVal) {
      previewGz()
    }
  }
)

const { gazetteer_id } = URLParamsToJSON(location.href)

if (gazetteer_id) {
  loadGz(gazetteer_id)
}

function loadGz(gzId) {
  isLoading.value = true
  Gazetteer.find(gzId)
    .then(({ body }) => {
      gz.value = body
      shapes.value = [
        {
          shape: body.shape,
          type: GZ_DATABASE,
          uuid: randomUUID()
        }
      ]
    })
    .catch(() => {})
    .finally(() => { isLoading.value = false })
}

function saveGz() {
  if (gz.value.id) {
    updateGz()
  } else {
    saveNewGz()
  }
}

function combineShapesToGz() {
  const geojson = shapes.value
    .filter((item) => item.type == GZ_LEAFLET)
    .map((item) => JSON.stringify(item.shape))

  const wkt = shapes.value
    .filter((item) => item.type == GZ_WKT)
    .map((item) => item.shape)

  const points = shapes.value
    .filter((item) => item.type == GZ_POINT)
    .map((item) => JSON.stringify(item.shape))

  const gaUnion = shapes.value
    .filter((item) => item.type == GZ_UNION_GA)
    .map((item) => item.shape.id)

  const gzUnion = shapes.value
    .filter((item) => item.type == GZ_UNION_GZ)
    .map((item) => item.shape.id)

  const gazetteer = {
    name: gz.value.name,
    iso_3166_a2: gz.value.iso_3166_a2,
    iso_3166_a3: gz.value.iso_3166_a3,
    shapes: {
      geojson,
      wkt,
      points,
      ga_union: gaUnion,
      gz_union: gzUnion
    }
  }

  return gazetteer
}

function shapesUpdated() {
  previewing.value = false
  // Bust the preview cache
  previewShape.value = null
}

function previewGz() {
  if (previewShape.value) {
    return
  }

  const gazetteer = combineShapesToGz()
  isLoading.value = true
  Gazetteer.preview({ gazetteer })
    .then(({ body }) => {
      previewShape.value =
      {
        shape: body.shape,
        type: GZ_LEAFLET,
        uuid: randomUUID()
      }
    })
    .catch(() => { previewing.value = false })
    .finally(() => { isLoading.value = false})
}

function saveNewGz() {
  const gazetteer = combineShapesToGz()

  isLoading.value = true
  Gazetteer.create({ gazetteer })
    .then(({ body }) => {
      gz.value = body
      shapes.value = [
        {
          shape: gz.value.shape,
          type: GZ_DATABASE,
          uuid: randomUUID()
        }
      ]
      SetParam(RouteNames.NewGazetteer, 'gazetteer_id', gz.value.id)
      shapesUpdated()
      TW.workbench.alert.create('New gazetteer created.', 'notice')
    })
    .catch(() => {})
    .finally(() => { isLoading.value = false })
}

function updateGz() {
  const gazetteer = {
    name: gz.value.name,
    iso_3166_a2: gz.value.iso_3166_a2,
    iso_3166_a3: gz.value.iso_3166_a3
  }

  isLoading.value = true
  Gazetteer.update(gz.value.id, { gazetteer })
    .then(({ body }) => {
      gz.value = body
      TW.workbench.alert.create('Gazetteer updated.', 'notice')
    })
    .catch(() => {})
    .finally(() => { isLoading.value = false })
}

function reset() {
  shapes.value = []
  previewing.value = false
  previewShape.value = null
  gz.value = {}
  SetParam(RouteNames.NewGazetteer, 'gazetteer_id')
}

usePopstateListener(() => {
  const { gazetteer_id } = URLParamsToJSON(location.href)
  if (gazetteer_id) {
    loadGz(gazetteer_id)
  } else {
    reset()
  }
})

function addToShapes(shape, type) {
  switch(type) {
    case GZ_LEAFLET:
    case GZ_POINT:
    case GZ_UNION_GA:
    case GZ_UNION_GZ:
      shapes.value.push({
        uuid: randomUUID(),
        type,
        shape
      })
      break
    case GZ_WKT:
      shapes.value.push({
        uuid: shape.uuid,
        type,
        shape: shape.wkt
      })
      break
  }
  shapesUpdated()
}

function removeFromShapes(shape) {
  removeFromArray(shapes.value, shape, { property: 'uuid' })
  shapesUpdated()
}

</script>

<style lang="scss" scoped>
.name-input {
  width: 400px;
}

.geolist {
  margin-bottom: 2em;
}
</style>