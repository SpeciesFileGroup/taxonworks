<template>
  <FacetContainer>
    <h3>Namespace</h3>
    <div
      v-for="param in PARAMETERS"
      :key="param"
      class="field"
    >
      <label class="d-block">{{ humanize(param) }}</label>
      <input
        type="text"
        v-model="params[param]"
        class="full_width"
      />
    </div>
  </FacetContainer>
</template>

<script setup>
import { onBeforeMount } from 'vue'
import { URLParamsToJSON } from '@/helpers/url/parse.js'
import { humanize } from '@/helpers'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'

const PARAMETERS = ['name', 'short_name', 'verbatim_short_name', 'institution']

const params = defineModel({
  type: Object,
  default: () => ({})
})

onBeforeMount(() => {
  const urlParams = URLParamsToJSON(location.href)

  PARAMETERS.forEach((param) => {
    params.value[param] = urlParams[param]
  })
})
</script>
