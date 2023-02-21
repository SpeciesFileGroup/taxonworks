<template>
  <VModal>
    <template #header>
      <h3>Select OTU</h3>
    </template>
    <template #body>
      <SmartSelector
        model="otus"
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
import { BIOLOGICAL_ASSOCIATION } from 'constants/index.js'

const emit = defineEmits('close')
const store = useGraphStore()
</script>
