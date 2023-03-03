<template>
  <FacetContainer>
    <h3>Type</h3>
    <ul class="no_bullets context-menu">
      <li
        v-for="(item, key) in TYPES"
        :key="key"
      >
        <label class="capitalize">
          <input
            v-model="params.source_type"
            :value="item"
            type="radio"
          >
          {{ key }}
        </label>
      </li>
    </ul>
  </FacetContainer>
</template>

<script setup>
import { computed } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'

const TYPES = {
  Any: undefined,
  Bibtex: 'Source::Bibtex',
  Verbatim: 'Source::Verbatim',
  Person: 'Source::Human'
}

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

params.value.source_type = URLParamsToJSON(location.href).source_type

</script>
