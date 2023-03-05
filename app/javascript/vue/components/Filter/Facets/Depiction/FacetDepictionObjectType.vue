<template>
  <FacetContainer>
    <h3>Depiction object type</h3>
    <ul class="no_bullets">
      <li
        v-for="type in DEPICTION_OBJECT_TYPES"
        :key="type"
      >
        <label>
          <input
            type="checkbox"
            :value="type"
            v-model="selectedDepictionObjectTypes"
          />
          {{ type }}
        </label>
      </li>
    </ul>
  </FacetContainer>
</template>

<script setup>
import { computed } from 'vue'
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'

const DEPICTION_OBJECT_TYPES = [
  'CharacterState',
  'CollectingEvent',
  'CollectionObject',
  'Content',
  'Descriptor',
  'Label',
  'Loan',
  'Observation',
  'Otu',
  'Person',
  'TaxonDetermination',
  'TaxonName'
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

const selectedDepictionObjectTypes = computed({
  get: () => props.modelValue.depiction_object_type || [],
  set: (value) => {
    params.value.depiction_object_type = value
  }
})
</script>
