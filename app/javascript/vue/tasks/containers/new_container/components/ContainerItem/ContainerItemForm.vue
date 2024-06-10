<template>
  <div>
    <div v-if="containerItem.objectId">
      <p>{{ containerItem.label }}</p>
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
  containerItem.value.objectId = id
  containerItem.value.objectType = selectedType.value
  containerItem.value.label = label
}
</script>
