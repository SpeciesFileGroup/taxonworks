<template>
  <FacetContainer>
    <h3>Observation type</h3>
    <ul class="no_bullets">
      <li
        v-for="(type, label) in observationTypes"
        :key="type"
      >
        <label>
          <input
            type="checkbox"
            :value="type"
            v-model="selectedObservationTypes"
          />
          {{ label }}
        </label>
      </li>
    </ul>
  </FacetContainer>
</template>

<script setup>
import { computed } from 'vue'
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import observationTypes from 'tasks/observation_matrices/matrix_row_coder/store/helpers/ObservationTypes.js'

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

const selectedObservationTypes = computed({
  get: () => props.modelValue.observation_type || [],
  set: (value) => {
    params.value.observation_type = value
  }
})
</script>
