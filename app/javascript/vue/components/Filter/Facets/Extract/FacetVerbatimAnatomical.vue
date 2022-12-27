<template>
  <FacetContainer>
    <h3>Verbatim anatomical origin</h3>
    <div class="field label-above">
      <label>Verbatim anatomical origin</label>
      <input
        type="text"
        class="full_width"
        v-model="params.verbatim_anatomical_origin"
      >
      <label>
        <input
          type="checkbox"
          v-model="params.exact_verbatim_anatomical_origin"
        >
        Exact
      </label>
    </div>
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

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})
</script>
