<template>
  <FacetContainer>
    <h3>Regular expression</h3>
    <input
      class="full_width"
      v-model="params.regex"
      type="text"
    >
  </FacetContainer>
</template>

<script setup>
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import { computed } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,

  set: value => {
    emit('update:modelValue', value)
  }
})

const { regex } = URLParamsToJSON(location.href)
params.value.regex = regex

</script>
