<template>
  <VModal :container-style="{ width: '800px' }">
    <template #header><h3>Citations</h3></template>
    <template #body>
      <FormCitation
        v-model="citation"
        :submit-button="{ color: 'primary', label: 'Add' }"
        @submit="($event) => emit('add:citation', $event)"
      />
    </template>
  </VModal>
</template>

<script setup>
import VModal from 'components/ui/Modal'
import FormCitation from 'components/Form/FormCitation.vue'
import { ref } from 'vue'

const props = defineProps({
  citations: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['add:citation'])
const citation = ref({})
</script>
