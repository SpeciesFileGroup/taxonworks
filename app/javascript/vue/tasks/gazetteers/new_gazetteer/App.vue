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
      v-model="name"
    />
  </div>

  <div class="editing-note">
    <ul>
      <li>
        Multiple shapes will be combined into a single collection.
      </li>
      <li>
        Once saved you can no longer edit the shape(s), instead you can delete
        and recreate.
      </li>
      <li>
        Overlapping shapes are discouraged and may give unexpected results.
      </li>
    </ul>

  </div>
  <Leaflet
    :shapes="leafletShapes"
    @shapes-updated="(shape) => addToShapes(shape)"
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
import ConfirmationModal from '@/components/ConfirmationModal.vue'
import DisplayList from './components/DisplayList.vue'
import Leaflet from './components/Leaflet.vue'
import NavBar from './components/NavBar.vue'
import { Gazetteer } from '@/routes/endpoints'
import { computed, ref } from 'vue'
import { addToArray, removeFromArray } from '@/helpers/arrays'

const shapes = ref([])
const gz = ref({})
const name = ref('')
const geoItemComponent = ref(null)

const leafletShapes = computed(() => {
  return shapes.value.map((item) => item.shape)
})

const saveDisabled = computed(() => {
  return !(name.value) || shapes.value.length == 0
})

function saveGz() {
  if (gz.value.id) {
    updateGz()
  } else {
    saveNewGz()
  }
}

function saveNewGz() {
  const geojson = shapes.value.map((item) => {
    return JSON.stringify(item.shape)
  })

  const gazetteer = {
    name: name.value,
    shapes: { geojson }
  }

  Gazetteer.create({ gazetteer })
    .then(({ body }) => {
      gz.value = body
    })
    .catch(() => {})
}

function updateGz() {
  const gazetteer = {
    name: name.value
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
  name.value = ''
}

// TODO make types a constant
function addToShapes(shape) {
  shapes.value.push({
    uuid: crypto.randomUUID(),
    type: 'leaflet',
    shape
  })
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