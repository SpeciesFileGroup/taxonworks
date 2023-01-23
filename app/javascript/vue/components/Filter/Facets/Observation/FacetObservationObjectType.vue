<template>
  <FacetContainer>
    <h3>Observation object type</h3>
    <ul class="no_bullets">
      <li
        v-for="(label, type) in OPTIONS"
        :key="type"
      >
        <label>
          <input
            type="checkbox"
            :value="type"
            v-model="selectedObservationObjectTypes"
          />
          {{ label }}
        </label>
      </li>
    </ul>
  </FacetContainer>
</template>

<script setup>
import { computed } from 'vue'
import { EXTRACT, COLLECTION_OBJECT, OTU } from 'constants/index.js'
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'

const OPTIONS = {
  [EXTRACT]: 'Extract',
  [COLLECTION_OBJECT]: 'Collection object',
  [OTU]: 'OTU'
}

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

const selectedObservationObjectTypes = computed({
  get: () => props.modelValue.observation_object_type || [],
  set: (value) => {
    params.value.observation_object_type = value
  }
})
</script>
