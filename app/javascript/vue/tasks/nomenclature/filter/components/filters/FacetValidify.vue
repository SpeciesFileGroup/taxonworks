<template>
  <FacetContainer class="validify">
    <h3>Validify</h3>
    <label>
      <input
        type="checkbox"
        v-model="params.validify"
      >
      Convert result to their valid names
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

  set: value => emit('update:modelValue', value)
})
</script>

<style scoped>
  .validify {
    background-color: #fff1d5;
  }
</style>
