<template>
  <FacetContainer>
    <h3>By attributes</h3>
    <ByAttribute
      :controller="controller"
      :exclude="exclude"
      v-model="params"
    />
  </FacetContainer>
</template>

<script setup>
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import ByAttribute from './ByAttribute.vue'
import { computed } from 'vue'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  },

  controller: {
    type: String,
    required: true
  },

  exclude: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits('update:modelValue')

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})
</script>
