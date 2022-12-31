<template>
  <FacetContainer>
    <h3>Citations</h3>
    <ul class="no_bullets">
      <li
        v-for="option in OPTIONS"
        :key="option.value"
      >
        <label>
          <input
            :value="option.value"
            v-model="params.citations"
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
import { onBeforeMount, computed } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'

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
    label: 'With/out citations',
    value: undefined
  },
  {
    label: 'Without origin citation',
    value: 'without_origin_citation'
  },
  {
    label: 'Without citations',
    value: 'without_citations'
  }
]

onBeforeMount(() => {
  params.value.citations = URLParamsToJSON(location.href).citations
})
</script>
