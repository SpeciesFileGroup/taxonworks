<template>
  <FacetContainer>
    <h3>Date</h3>
    <div class="horizontal-left-content">
      <div class="field label-above margin-medium-right">
        <label>Start year</label>
        <input
          type="text"
          class="full_width"
          :maxlength="4"
          v-model="params.year_start"
        >
      </div>
      <div class="field label-above">
        <label>End year</label>
        <input
          type="text"
          :maxlength="4"
          class="full_width"
          v-model="params.year_end"
        >
      </div>
    </div>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { computed, onBeforeMount } from 'vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: undefined
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

onBeforeMount(() => {
  const urlParams = URLParamsToJSON(location.href)

  params.value.year_start = urlParams.year_start
  params.value.year_end = urlParams.year_end
})
</script>
