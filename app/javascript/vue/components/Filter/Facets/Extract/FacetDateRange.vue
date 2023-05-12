<template>
  <FacetContainer>
    <h3>Extracted date range</h3>
    <div class="horizontal-left-content">
      <div class="field separate-right label-above">
        <label>Start date</label>
        <input
          type="date"
          v-model="date.extract_start_date_range"
        >
      </div>

      <div class="field label-above">
        <label>End date</label>
        <input
          type="date"
          v-model="date.extract_end_date_range"
        >
      </div>
    </div>
  </FacetContainer>
</template>

<script setup>
import { computed } from 'vue'
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({
      extract_start_date_range: undefined,
      extract_end_date_range: undefined
    })
  }
})

const emit = defineEmits(['update:modelValue'])

const date = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

</script>
