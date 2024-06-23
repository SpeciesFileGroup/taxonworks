<template>
  <NavBar>
    <div class="flex-separate full_width">
      <div class="middle margin-small-left">
        <span
          v-if="gaz.id"
          class="margin-small-left"
          v-html="gaz.object_tag"
        />
        <span
          class="margin-small-left"
          v-else
        >
          New gazetteer
        </span>
        <div
          v-if="gaz.id"
          class="horizontal-left-content margin-small-left gap-small"
        >
          <VPin
            class="circle-button"
            :object-id="gaz.id"
            type="Gazetteer"
          />
          <RadialAnnotator :global-id="gaz.global_id" />
          <RadialNavigator :global-id="gaz.global_id" />
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
            :disabled="!gaz.id"
            @click="cloneGaz"
          >
            Clone
          </VBtn>
          <VBtn
            :disabled="saveDisabled"
            @click="saveGaz"
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
    You can create multiple shapes which will be saved as a single collection. Once saved you can no longer edit the shape(s), instead you can delete and recreate.
  </div>
  <GeographicItem
    @shapes-updated="(shapes) => leafletShapes = shapes"
    :editing-disabled="shapeSaved"
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

let leafletShapes = []

const gaz = ref({})
const name = ref('')
const saveLabel = ref('Save')
const shapeSaved = ref(false)

const saveDisabled = computed(() => {
  return !(name.value) || leafletShapes.length == 0
})

function saveGaz() {
  let shape = leafletShapes.value[0]
  shape.properties.data_type = 'geography'
  const gazetteer = {
    name: name.value,
    geographic_item_attributes: { shape: JSON.stringify(shape) },
  }

  Gazetteer.create({ gazetteer })
    .then(() => {
      shapeSaved.value = true
      saveLabel.value = 'Update name'
    })
    .catch(() => {})
}

function cloneGaz() {}

function reset() {}

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