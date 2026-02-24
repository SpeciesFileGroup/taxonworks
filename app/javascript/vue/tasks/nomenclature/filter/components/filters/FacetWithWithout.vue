<template>
  <FacetContainer>
    <h3>{{ title }}</h3>
    <ul class="no_bullets">
      <li
        v-for="option in OPTIONS"
        :key="option.value"
      >
        <label>
          <input
            :value="option.value"
            v-model="params[paramKey]"
            type="radio"
          />
          {{ option.label }}
        </label>
      </li>
    </ul>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import { onBeforeMount } from 'vue'
import { URLParamsToJSON } from '@/helpers/url/parse.js'

const props = defineProps({
  paramKey: {
    type: String,
    required: true
  },

  title: {
    type: String,
    required: true
  },

  withText: {
    type: String,
    required: true
  },

  withoutText: {
    type: String,
    required: true
  },

  eitherText: {
    type: String,
    required: true
  },
})

const params = defineModel({
  type: Object,
  default: () => ({})
})

const OPTIONS = [
  {
    label: props.eitherText,
    value: undefined
  },
  {
    label: props.withText,
    value: true
  },
  {
    label: props.withoutText,
    value: false
  }
]

onBeforeMount(() => {
  params.value[props.paramKey] = URLParamsToJSON(location.href)[props.paramKey]
})
</script>
