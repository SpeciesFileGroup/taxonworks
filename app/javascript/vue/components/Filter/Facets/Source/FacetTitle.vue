<template>
  <FacetContainer>
    <h3>Text in</h3>
    <div class="field label-above">
      <label>Full citation</label>
      <input
        type="text"
        class="full_width"
        v-model="params.query_term"
      >
    </div>
    <div class="field label-above">
      <label>Title</label>
      <input
        type="text"
        class="full_width"
        v-model="params.title"
      >
      <label class="horizontal-left-content">
        <input
          type="checkbox"
          v-model="params.exact_title"
        >
        Exact
      </label>
    </div>
  </FacetContainer>
</template>

<script setup>
import { computed, onBeforeMount } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: undefined
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

onBeforeMount(() => {
  const urlParams = URLParamsToJSON(location.href)

  params.value.title = urlParams.title
  params.value.exact_title = urlParams.exact_title
  params.value.query_term = urlParams.query_term
})
</script>
