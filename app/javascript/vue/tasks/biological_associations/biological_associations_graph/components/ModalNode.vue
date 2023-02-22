<template>
  <VModal>
    <template #header>
      <h3>Select OTU</h3>
    </template>
    <template #body>
      <SmartSelector
        :model="MODEL_TYPE[store.currentNodeType]"
        :target="BIOLOGICAL_ASSOCIATION"
        @selected="
          ($event) => {
            store.createNode($event)
            emit('close')
          }
        "
      />
    </template>
  </VModal>
</template>

<script setup>
import SmartSelector from 'components/ui/SmartSelector'
import VModal from 'components/ui/Modal.vue'
import { useGraphStore } from '../store/useGraphStore'
import {
  BIOLOGICAL_ASSOCIATION,
  OTU,
  COLLECTION_OBJECT
} from 'constants/index.js'

const MODEL_TYPE = {
  [OTU]: 'otus',
  [COLLECTION_OBJECT]: 'collection_objects'
}

const emit = defineEmits('close')
const store = useGraphStore()
</script>
