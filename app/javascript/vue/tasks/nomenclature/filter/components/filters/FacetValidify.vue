<template>
  <FacetContainer highlight>
    <h3>Validify</h3>
    <label>
      <input
        type="checkbox"
        v-model="inputValue"
      />
      Convert result to their valid names
    </label>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import { useYellowFacetCheckbox } from '../../utils/resetYellowFacets'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})
const emit = defineEmits('update:modelValue')

const inputValue = useYellowFacetCheckbox(props, emit, 'validify')
</script>
