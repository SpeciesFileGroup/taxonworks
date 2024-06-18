<template>
  <div class="field">
    <div
      v-if="containerItem.objectId"
      class="horizontal-left-content gap-small"
    >
      <p>{{ containerItem.label }}</p>
      <VBtn
        circle
        color="primary"
        @click="unsetContainerObject"
      >
        <VIcon
          name="undo"
          small
        />
      </VBtn>
    </div>

    <VAutocomplete
      v-else
      param="term"
      label="label"
      :url="TYPES[selectedType].autocomplete"
      :placeholder="TYPES[selectedType].placeholder"
      @get-item="setContainedObject"
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { COLLECTION_OBJECT } from '@/constants'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const TYPES = {
  [COLLECTION_OBJECT]: {
    autocomplete: '/collection_objects/autocomplete',
    placeholder: 'Search a collection object...'
  }
}

const containerItem = defineModel({
  type: Object,
  required: true
})

const selectedType = ref(COLLECTION_OBJECT)

function setContainedObject({ id, label }) {
  Object.assign(containerItem.value, {
    objectId: id,
    objectType: selectedType.value,
    label: label,
    isUnsaved: true
  })
}

function unsetContainerObject() {
  Object.assign(containerItem.value, {
    objectId: null,
    objectType: null,
    label: null,
    isUnsaved: true
  })
}
</script>
