<template>
  <FacetContainer>
    <h3>Observation matrix</h3>
    <ul class="no_bullets">
      <li
        v-for="(label, type) in DescriptorTypes"
        :key="type"
      >
        <label>
          <input
            type="checkbox"
            :value="type"
            v-model="selectedDescriptorTypes"
          >
          {{ label }}
        </label>
      </li>
    </ul>
  </FacetContainer>
</template>

<script setup>
import { computed } from 'vue'
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import DescriptorTypes from 'tasks/descriptors/new/const/types.js'

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

const selectedDescriptorTypes = computed({
  get: () => props.modelValue.descriptor_types || [],
  set: value => {
    params.value.descriptor_types = value
  }
})
</script>
