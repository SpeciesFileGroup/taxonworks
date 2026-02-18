<template>
  <FacetContainer>
    <h3>{{ title }}</h3>
    <div class="field">
      <input
        type="text"
        v-model="params[paramText]"
        class="full_width"
      />
    </div>
    <label v-if="paramExact">
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
    default: undefined
  }
})

const params = defineModel({
  type: Object,
  default: () => ({})
})

onBeforeMount(() => {
  const urlParams = URLParamsToJSON(location.href)

  params.value[props.paramText] = urlParams[props.paramText]

  if (props.paramExact) {
    params.value[props.paramExact] = urlParams[props.paramExact]
  }
})
</script>
