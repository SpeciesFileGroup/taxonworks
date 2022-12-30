<template>
  <FacetContainer>
    <h3>Nomenclature rank</h3>
    <ul class="no_bullets">
      <li
        v-for="option in OPTIONS"
        :key="option.value"
      >
        <label>
          <input
            :value="option.value"
            v-model="params.nomenclature_group"
            type="radio"
          >
          {{ option.label }}
        </label>
      </li>
    </ul>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import { computed, onBeforeMount } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'

const OPTIONS = [
  {
    label: 'Any rank',
    value: undefined
  },
  {
    label: 'Higher',
    value: 'Higher'
  },
  {
    label: 'Family group',
    value: 'Family'
  },
  {
    label: 'Genus group',
    value: 'Genus'
  },
  {
    label: 'Species group',
    value: 'Species'
  }
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

onBeforeMount(() => {
  params.value.nomenclature_group = URLParamsToJSON(location.href).nomenclature_group
})
</script>
