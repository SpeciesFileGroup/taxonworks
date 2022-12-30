<template>
  <FacetContainer>
    <h3>Nomenclature code</h3>
    <ul class="no_bullets">
      <li
        v-for="option in OPTIONS"
        :key="option.value"
      >
        <label>
          <input
            :value="option.value"
            v-model="params.nomenclature_code"
            type="radio"
          >
          {{ option.label }}
        </label>
      </li>
    </ul>
  </FacetContainer>
</template>

<script setup>
import { computed, onBeforeMount } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'

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

const OPTIONS = [
  {
    label: 'Any code',
    value: undefined
  },
  {
    label: 'ICZN (animals)',
    value: 'Iczn'
  },
  {
    label: 'ICN (plants)',
    value: 'Icn'
  },
  {
    label: 'ICNP (bacteria)',
    value: 'Icnp'
  },
  {
    label: 'ICVCN (viruses)',
    value: 'Icvcn'
  }
]

onBeforeMount(() => {
  params.value.nomenclature_code = URLParamsToJSON(location.href).nomenclature_code
})
</script>
