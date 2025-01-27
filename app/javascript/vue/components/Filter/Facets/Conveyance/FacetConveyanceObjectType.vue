<template>
  <FacetContainer>
    <h3>Conveyance object type</h3>
    <ul class="no_bullets">
      <li
        v-for="type in CONVEYANCE_OBJECT_TYPES"
        :key="type"
      >
        <label>
          <input
            type="checkbox"
            :value="type"
            v-model="selectedConveyanceObjectTypes"
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

const CONVEYANCE_OBJECT_TYPES = ['CollectionObject', 'FieldOccurrence', 'Otu']

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

const selectedConveyanceObjectTypes = computed({
  get: () => props.modelValue.conveyance_object_type || [],
  set: (value) => {
    params.value.conveyance_object_type = value
  }
})
</script>
