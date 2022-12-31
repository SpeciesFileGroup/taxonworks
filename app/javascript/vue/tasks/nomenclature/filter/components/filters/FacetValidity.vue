<template>
  <FacetContainer>
    <h3>Validity</h3>
    <ul class="no_bullets">
      <li
        v-for="option in OPTIONS"
        :key="option.value"
      >
        <label>
          <input
            :value="option.value"
            v-model="params.validity"
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
    label: 'in/valid',
    value: undefined
  },
  {
    label: 'only valid',
    value: true
  },
  {
    label: 'only invalid',
    value: false
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
  set: value => emit('update:modelValue', value)
})

onBeforeMount(() => {
  params.value.validity = URLParamsToJSON(location.href).validity
})
</script>
