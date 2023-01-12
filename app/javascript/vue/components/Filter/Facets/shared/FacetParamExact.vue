<template>
  <FacetContainer>
    <h3>{{ title }}</h3>
    <div class="field label-above">
      <label class="capitalize">{{ param }}</label>
      <input
        class="full_width"
        v-model="params[param]"
        type="text"
      >
      <label>
        <input
          v-model="params[`${param}_exact`]"
          type="checkbox"
        >
        Exact
      </label>
    </div>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import { computed, onBeforeMount } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  },

  title: {
    type: String,
    required: true
  },

  param: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

onBeforeMount(() => {
  const urlParams = URLParamsToJSON(location.href)

  params.value[props.param] = urlParams[props.param]
  params.value[`${props.param}_exact`] = urlParams[`${props.param}_exact`]
})
</script>
