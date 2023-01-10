<template>
  <FacetContainer>
    <h3>OTU</h3>
    <div class="field label-above">
      <label class="capitalize">Name</label>
      <input
        class="full_width"
        v-model="params.name"
        type="text"
      >
      <label>
        <input
          v-model="params.name_exact"
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
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

onBeforeMount(() => {
  const urlParams = URLParamsToJSON(location.href)

  params.value.name = urlParams.name
  params.value.name_exact = urlParams.name_exact
})
</script>
