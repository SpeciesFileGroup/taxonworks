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
        Once saved you can no longer edit the shape(s), instead you can delete and recreate.
      </li>
      <li>
        Overlapping shapes are discouraged and may give unexpected results.
      </li>
    </ul>

  </div>
  <GeographicItem
    @shapes-updated="(shapes) => leafletShapes = shapes"
    :editing-disabled="!!gz.id"
    ref="geoItemComponent"
  />
</template>

<script setup>
import ConfirmationModal from '@/components/ConfirmationModal.vue'
import GeographicItem from './components/GeographicItem.vue'
import NavBar from './components/NavBar.vue'
import { Gazetteer } from '@/routes/endpoints'
import { computed, ref } from 'vue'

let leafletShapes = ref([])
const gz = ref({})
const name = ref('')
const geoItemComponent = ref(null)

const saveDisabled = computed(() => {
  return !(name.value) || leafletShapes.value.length == 0
})

function saveGz() {
  if (gz.value.id) {
    updateGz()
  } else {
    saveNewGz()
  }
}

function saveNewGz() {
  const geojson = leafletShapes.value.map((shape) => {
    delete shape['uuid']
    return JSON.stringify(shape)
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
  geoItemComponent.value.reset()
  gz.value = {}
  name.value = ''
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
</style>