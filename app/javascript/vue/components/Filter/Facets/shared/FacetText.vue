<template>
  <FacetContainer>
    <h3> {{ title }} </h3>
    <div class="field">
      <input
        type="text"
        v-model="params[paramText]"
        class="full_width"
      />
    </div>
    <label>
      <input
        v-model="params[paramExact]"
        type="checkbox"
      />
      Exact
    </label>
  </FacetContainer>
</template>

<script setup>
import { onBeforeMount } from 'vue'
import { URLParamsToJSON } from '@/helpers/url/parse.js'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'

const props = defineProps({
  title: {
    type: String,
    default: 'Depiction caption'
  },

  paramText: {
    type: String,
    required: true
  },

  paramExact: {
    type: String,
    required: true
  },
})

const params = defineModel({
  type: Object,
  default: () => ({})
})

onBeforeMount(() => {
  const urlParams = URLParamsToJSON(location.href)
  params.value[props.paramText] = urlParams[props.paramText]
})
</script>

<style scoped>
</style>
