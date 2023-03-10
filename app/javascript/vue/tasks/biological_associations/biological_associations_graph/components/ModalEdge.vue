<template>
  <VModal>
    <template #header>
      <h3>Select a biological relationship</h3>
    </template>
    <template #body>
      <SmartSelector
        model="biological_relationships"
        autofocus
        @selected="($event) => emit('add:relationship', $event)"
      />
    </template>
  </VModal>
</template>

<script setup>
import SmartSelector from 'components/ui/SmartSelector'
import VModal from 'components/ui/Modal.vue'

const emit = defineEmits(['add:relationship'])
</script>
