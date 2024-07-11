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

  <div
    class="horizontal-left-content margin-medium-top margin-medium-bottom"
  >
    <WktComponent
      :disabled="!!gz.id"
      :type="GZ_WKT"
      id_key="uuid"
      :id_generator="() => randomUUID()"
      @create="(wkt) => addToShapes(wkt, GZ_WKT)"
      class="margin-small-right"
    >
      <template #header>
        <h3>Create WKT shape</h3>
      </template>
    </WktComponent>
<!--
    <manually-component
      class="margin-small-right"
      @create="addGeoreference($event, GEOREFERENCE_POINT)"
    />
    <geolocate-component
      :disabled="!collectingEvent.id"
      class="margin-small-right"
      @create="addToQueue"
    />
-->
  </div>

  <Leaflet
    :shapes="leafletShapes"
    @shapes-updated="(shape) => addToShapes(shape, GZ_LEAFLET)"
    :editing-disabled="!!gz.id"
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
import SetParam from '@/helpers/setParam'
import WktComponent from '@/tasks/collecting_events/new_collecting_event/components/parsed/georeferences/wkt.vue'
import { Gazetteer } from '@/routes/endpoints'
import { computed, ref } from 'vue'
import { randomUUID } from '@/helpers'
import { RouteNames } from '@/routes/routes'
import { addToArray, removeFromArray } from '@/helpers/arrays'
import { URLParamsToJSON } from '@/helpers/url/parse'
import { usePopstateListener } from '@/composables'
import {
  //GZ_POINT,
  GZ_WKT,
  GZ_LEAFLET
} from '@/constants/index.js'

const shapes = ref([])
const gz = ref({})
const geoItemComponent = ref(null)
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

  const gazetteer = {
    name: gz.value.name,
    shapes: {
      geojson,
      wkt
    }
  }

  Gazetteer.create({ gazetteer })
    .then(({ body }) => {
      gz.value = body
      shapes.value = [
      {
        shape: gz.value.shape,
        type: GZ_LEAFLET
      }
    ]
      SetParam(RouteNames.NewGazetteer, 'gazetteer_id', gz.value.id)
    })
    .catch(() => {})
}

function updateGz() {
  const gazetteer = {
    name: gz.value.name
  }

  Gazetteer.update(gz.value.id, { gazetteer })
    .then(({ body }) => {
      gz.value = body
    })
    .catch(() => {})
}

function cloneGz() {}

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
        shape: shape.wkt
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
  margin-left: 10vw;
  margin-bottom: 6px;
}

.geolist {
  margin-bottom: 2em;
}
</style>