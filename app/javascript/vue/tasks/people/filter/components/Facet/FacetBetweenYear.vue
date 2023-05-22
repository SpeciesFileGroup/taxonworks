<template>
  <FacetContainer>
    <h3>{{ title }}</h3>
    <div class="horizontal-left-content align-start field">
      <div class="margin-small-right">
        <label>Before</label>
        <input
          type="number"
          v-model="params[beforeParam]"
        >
      </div>
      <div>
        <label>After</label>
        <input
          type="number"
          v-model="params[afterParam]"
        >
      </div>
    </div>
  </FacetContainer>
</template>

<script setup>
import { computed, onBeforeMount } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse'
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  },

  title: {
    type: String,
    required: true
  },

  beforeParam: {
    type: String,
    required: true
  },

  afterParam: {
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

  params.value[props.beforeParam] = urlParams[props.beforeParam]
  params.value[props.afterParam] = urlParams[props.afterParam]
})
</script>
