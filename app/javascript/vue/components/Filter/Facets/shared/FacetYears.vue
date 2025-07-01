<template>
  <FacetContainer>
    <h3> {{ title }} </h3>
    <div class="field">
      <label>Year:</label>
      <br />
      <input
        type="number"
        v-between-numbers="[minYear, maxYear]"
        v-model="params[paramYear]"
      />
    </div>

    <div class="margin-medium-bottom">
      Or
    </div>

    <fieldset>
      <legend>Range</legend>
      <div class="field">
        <label>After:</label>
        <br />
        <input
          type="number"
          v-between-numbers="[minYear, maxYear]"
          v-model="params[paramAfter]"
        />
      </div>
      <div class="field">
        <label>Prior to:</label>
        <br />
        <input
          type="number"
          v-between-numbers="[minYear, maxYear]"
          v-model="params[paramPriorTo]"
        />
      </div>
    </fieldset>
  </FacetContainer>
</template>

<script setup>
import { onBeforeMount } from 'vue'
import { URLParamsToJSON } from '@/helpers/url/parse.js'
import { vBetweenNumbers } from '@/directives/betweenNumbers'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'

const props = defineProps({
  title: {
    type: String,
    default: 'Copyright year'
  },
  paramPriorTo: {
    type: String,
    default: 'copyright_prior_to_year'
  },
  paramAfter: {
    type: String,
    default: 'copyright_after_year'
  },
  paramYear: {
    type: String,
    default: 'copyright_year'
  },
  minYear: {
    type: Number,
    default: 1000
  },
  maxYear: {
    type: Number,
    default: (new Date().getFullYear()) + 5
  }
})

const params = defineModel({
  type: Object,
  default: () => ({})
})

onBeforeMount(() => {
  const urlParams = URLParamsToJSON(location.href)
  params.value[props.paramPriorTo] = urlParams[props.paramPriorTo]
  params.value[props.paramAfter] = urlParams[props.paramAfter]
  params.value[props.paramYear] = urlParams[props.paramYear]
})
</script>

<style scoped>
</style>
