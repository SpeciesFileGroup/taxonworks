<template>
  <FacetContainer>
    <h3>Name</h3>
    <input
      type="text"
      v-model="params.name"
    />
    <label>
      <input
        type="checkbox"
        v-model="params.name_exact"
      />
      Exact
    </label>
  </FacetContainer>
</template>

<script setup>
import { computed } from 'vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})
</script>
