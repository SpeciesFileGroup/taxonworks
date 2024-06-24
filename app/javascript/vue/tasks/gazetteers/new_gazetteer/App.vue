<template>
  <!-- TODO Add spinner -->
  <NavBar>
    <div class="flex-separate full_width">
      <div class="middle margin-small-left">
        <span
          class="margin-small-left"
        >
          {{ headerLabel }}
        </span>
        <div
          v-if="gz.id"
          class="horizontal-left-content margin-small-left gap-small"
        >
          <VPin
            class="circle-button"
            :object-id="gz.id"
            type="Gazetteer"
          />
          <!-- TODO complains when undefined instead of "" or something-->
          <RadialAnnotator :global-id="gz.global_id" />
          <RadialNavigator :global-id="gz.global_id" />
        </div>
      </div>
      <ul class="context-menu no_bullets">
        <li class="horizontal-right-content">
          <span
            v-if="isUnsaved"
            class="medium-icon margin-small-right"
            title="You have unsaved changes."
            data-icon="warning"
          />
          <VBtn
            type="button"
            class="button normal-input button-submit margin-small-right"
            :disabled="!gz.id"
            @click="cloneGz"
          >
            Clone
          </VBtn>
          <VBtn
            :disabled="saveDisabled"
            @click="saveGz"
            class="button normal-input button-submit button-size margin-small-right"
            type="button"
          >
            {{ saveLabel }}
          </VBtn>
          <VBtn
            @click="reset"
            class="button normal-input button-default button-size"
            type="button"
          >
            New
          </VBtn>
        </li>
      </ul>
    </div>
    <ConfirmationModal ref="confirmationModal" />
  </NavBar>

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
import NavBar from '@/components/layout/NavBar.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VPin from '@/components/ui/Button/ButtonPin.vue'
import { Gazetteer } from '@/routes/endpoints'
import { computed, ref } from 'vue'

let leafletShapes = ref([])
const gz = ref({})
const name = ref('')
const saveLabel = ref('Save')
const geoItemComponent = ref(null)

const saveDisabled = computed(() => {
  return !(name.value) || leafletShapes.value.length == 0
})

const headerLabel = computed(() => {
  return gz.value.id ? gz.value.name : 'New Gazetteer'
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
      saveLabel.value = 'Update name'
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
  saveLabel.value = 'Save'
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