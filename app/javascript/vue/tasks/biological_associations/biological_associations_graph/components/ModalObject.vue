<template>
  <VModal>
    <template #header>
      <h3>Select {{ type }}</h3>
    </template>
    <template #body>
      <SmartSelector
        :model="MODEL_TYPE[props.type]"
        :target="BIOLOGICAL_ASSOCIATION"
        @selected="($event) => emit('addObject', $event)"
      />
    </template>
  </VModal>
</template>

<script setup>
import SmartSelector from 'components/ui/SmartSelector'
import VModal from 'components/ui/Modal.vue'
import {
  BIOLOGICAL_ASSOCIATION,
  OTU,
  COLLECTION_OBJECT
} from 'constants/index.js'

const props = defineProps({
  type: {
    type: String,
    required: true
  }
})
const MODEL_TYPE = {
  [OTU]: 'otus',
  [COLLECTION_OBJECT]: 'collection_objects'
}

const emit = defineEmits(['addObject'])
</script>
