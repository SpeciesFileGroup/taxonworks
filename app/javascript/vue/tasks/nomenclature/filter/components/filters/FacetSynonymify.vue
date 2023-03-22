<template>
  <FacetContainer highlight>
    <h3>Synonymify</h3>
    <label>
      <input
        type="checkbox"
        v-model="params.synonymify"
      />
      Expand to include synonyms
    </label>
  </FacetContainer>
</template>

<script setup>
import { computed } from 'vue'
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})
const emit = defineEmits('update:modelValue')

const params = computed({
  get: () => props.modelValue,

  set: (value) => emit('update:modelValue', value)
})
</script>
