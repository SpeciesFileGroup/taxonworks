<template>
  <VModal :container-style="{ width: '800px', minHeight: '50vh' }">
    <template #header>
      <h3>Select {{ type }}</h3>
    </template>
    <template #body>
      <SmartSelector
        :model="MODEL_TYPE[props.type].model"
        :target="BIOLOGICAL_ASSOCIATION"
        :otu-picker="type === OTU"
        :pin-section="MODEL_TYPE[props.type].section"
        autofocus
        @selected="($event) => emit('add:object', makeNodeObject($event))"
      />
    </template>
  </VModal>
</template>

<script setup>
import SmartSelector from '@/components/ui/SmartSelector'
import VModal from '@/components/ui/Modal.vue'
import {
  BIOLOGICAL_ASSOCIATION,
  OTU,
  COLLECTION_OBJECT
} from '@/constants/index.js'
import { makeNodeObject } from '../adapters'

const props = defineProps({
  type: {
    type: String,
    required: true
  }
})
const MODEL_TYPE = {
  [OTU]: {
    model: 'otus',
    section: 'Otus'
  },
  [COLLECTION_OBJECT]: {
    model: 'collection_objects',
    section: 'CollectionObjects'
  }
}

const emit = defineEmits(['add:object'])
</script>
