<template>
  <FacetContainer>
    <h3>Include</h3>
    <ul class="no_bullets">
      <li
        v-for="({ descendants, ancestors }, label) in options"
        :key="label"
      >
        <label>
          <input
            type="radio"
            :checked="params.ancestors == ancestors && params.descendants == descendants"
            :disabled="!(params.taxon_name_id && params.taxon_name_id.length)"
            @click="Object.assign(params, { ancestors, descendants })"
          >
          {{ label }}
        </label>
      </li>
    </ul>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import { computed, onBeforeMount } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'

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

const options = {
  'N/A': {
    descendants: undefined,
    ancestors: undefined
  },
  Ancestors: {
    descendants: undefined,
    ancestors: true
  },
  Descendants: {
    descendants: true,
    ancestors: undefined
  }
}

onBeforeMount(() => {
  const urlParams = URLParamsToJSON(location.href)

  params.value.descendants = urlParams.descendants
  params.value.ancestors = urlParams.ancestors
})
</script>
