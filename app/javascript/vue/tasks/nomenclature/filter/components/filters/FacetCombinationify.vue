<template>
  <FacetContainer highlight>
    <h3>Combinationify</h3>
    <label>
      <input
        type="checkbox"
        v-model="inputValue"
      />
      Expand to include combinations
    </label>
  </FacetContainer>
</template>

<script setup>
import { useYellowFacetCheckbox } from '../../utils/resetYellowFacets'
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})
const emit = defineEmits('update:modelValue')

const inputValue = useYellowFacetCheckbox(props, emit, 'combinationify')
</script>
