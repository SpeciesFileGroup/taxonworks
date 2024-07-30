<template>
  <!-- TODO Add spinner -->
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

  <div class="editing-note">
    <ul>
      <li>
        Multiple shapes will be combined into a single shape - a circle is
        transformed into a polygon approximating the circle.
      </li>
      <li>
        Once saved you can no longer edit the shape(s), instead you can delete
        and recreate.
      </li>
      <li>
        Overlapping shapes may give unexpected results.
      </li>
    </ul>

  </div>

  <OtherInputs
    :inputs-disabled="!!gz.id"
    @new-shape="(data, type) => addToShapes(data, type)"
  />

  <Leaflet
    :shapes="leafletShapes"
    @shapes-updated="(shape) => addToShapes(shape, GZ_LEAFLET)"
    :editing-disabled="!!gz.id"
  />

  <OtherInputs
    :inputs-disabled="!!gz.id"
    @new-shape="(data, type) => addToShapes(data, type)"
  />

  <DisplayList
    class="geolist"
    :list="shapes"
    @delete="(shape) => removeFromShapes(shape)"
    :editing-disabled="!!gz.id"
  />
</template>

<script setup>
import DisplayList from './components/DisplayList.vue'
import Leaflet from './components/Leaflet.vue'
import NavBar from './components/NavBar.vue'
import OtherInputs from './components/OtherInputs.vue'
import SetParam from '@/helpers/setParam'
import { Gazetteer } from '@/routes/endpoints'
import { computed, ref } from 'vue'
import { randomUUID } from '@/helpers'
import { RouteNames } from '@/routes/routes'
import { addToArray, removeFromArray } from '@/helpers/arrays'
import { URLParamsToJSON } from '@/helpers/url/parse'
import { usePopstateListener } from '@/composables'
import {
  GZ_POINT,
  GZ_WKT,
  GZ_LEAFLET
} from '@/constants/index.js'

const shapes = ref([])
const gz = ref({})
const loading = ref(false)
const leafletShapes = computed(() => {
  return shapes.value.map((item) => item.shape)
})

const saveDisabled = computed(() => {
  return !(gz.value.name) || shapes.value.length == 0
})

const { gazetteer_id } = URLParamsToJSON(location.href)

if (gazetteer_id) {
  loadGz(gazetteer_id)
}

function loadGz(gzId) {
  Gazetteer.find(gzId)
  .then(({ body }) => {
    gz.value = body
    shapes.value = [
      {
        shape: body.shape,
        type: GZ_LEAFLET
      }
    ]
  })
  .catch(() => {})
}

function saveGz() {
  if (gz.value.id) {
    updateGz()
  } else {
    saveNewGz()
  }
}

function saveNewGz() {
  const geojson = shapes.value
    .filter((item) => item.type == GZ_LEAFLET)
    .map((item) => JSON.stringify(item.shape))

  const wkt = shapes.value
    .filter((item) => item.type == GZ_WKT)
    .map((item) => item.shape)

  const points = shapes.value
    .filter((item) => item.type == GZ_POINT)
    .map((item) => JSON.stringify(item.shape))

  const gazetteer = {
    name: gz.value.name,
    iso_3166_a2: gz.value.iso_3166_a2,
    iso_3166_a3: gz.value.iso_3166_a3,
    shapes: {
      geojson,
      wkt,
      points
    }
  }

  Gazetteer.create({ gazetteer })
    .then(({ body }) => {
      gz.value = body
      shapes.value = [
      {
        shape: gz.value.shape,
        type: GZ_LEAFLET,
        uuid: randomUUID()
      }
    ]
      SetParam(RouteNames.NewGazetteer, 'gazetteer_id', gz.value.id)
      TW.workbench.alert.create('New gazetteer created.', 'notice')
    })
    .catch(() => {})
}

function updateGz() {
  const gazetteer = {
    name: gz.value.name,
    iso_3166_a2: gz.value.iso_3166_a2,
    iso_3166_a3: gz.value.iso_3166_a3
  }

  Gazetteer.update(gz.value.id, { gazetteer })
    .then(({ body }) => {
      gz.value = body
      TW.workbench.alert.create('Gazetteer updated.', 'notice')
    })
    .catch(() => {})
}

function reset() {
  shapes.value = []
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
      shapes.value.push({
        uuid: randomUUID(),
        type,
        // TODO should store this as stringified?
        shape
      })
      break
    case GZ_WKT:
      shapes.value.push({
        uuid: shape.uuid,
        type: GZ_WKT,
        // TODO can we turn this into something leaflet can display right now?
        shape: shape.wkt
      })
      break
    case GZ_POINT:
      shapes.value.push({
        uuid: randomUUID(),
        type,
        shape
      })
      break
  }
}

function removeFromShapes(shape) {
  removeFromArray(shapes.value, shape, { property: 'uuid' })
}

</script>

<style lang="scss" scoped>
.name-input {
  width: 400px;
}

.editing-note {
  //margin-left: 10vw;
  margin-bottom: 6px;
}

.editing-note > ul {
  padding-left: 1em;
}

.geolist {
  margin-bottom: 2em;
}
</style>