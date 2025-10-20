<template>
  <FacetContainer>
    <h3>Origin type</h3>
    <ul class="no_bullets">
      <li
        v-for="type in ORIGIN_TYPES"
        :key="type"
      >
        <label>
          <input
            type="checkbox"
            :value="type"
            v-model="selectedOriginTypes"
          />
          {{ type }}
        </label>
      </li>
    </ul>
  </FacetContainer>
</template>

<script setup>
import { computed } from 'vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'

const ORIGIN_TYPES = [
  'AnatomicalPart',
  'CollectionObject',
  'FieldOccurrence',
  'Otu'
]

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

const selectedOriginTypes = computed({
  get: () => props.modelValue.origin_object_type || [],
  set: (value) => {
    params.value.origin_object_type = value
  }
})
</script>
