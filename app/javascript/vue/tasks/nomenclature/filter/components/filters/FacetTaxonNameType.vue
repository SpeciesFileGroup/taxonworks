<template>
  <FacetContainer>
    <h3>Name type</h3>
    <ul class="no_bullets">
      <li
        v-for="(value, key) in TAXON_TYPES"
        :key="key"
      >
        <label>
          <input
            :value="value"
            v-model="params.taxon_name_type"
            type="radio"
          />
          {{ key }}
        </label>
      </li>
    </ul>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import { computed, onBeforeMount } from 'vue'
import { URLParamsToJSON } from '@/helpers/url/parse.js'

const TAXON_TYPES = {
  Protonym: 'Protonym',
  Combination: 'Combination',
  Hybrid: 'Hybrid',
  None: undefined
}

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

onBeforeMount(() => {
  params.value.taxon_name_type = URLParamsToJSON(location.href).taxon_name_type
})
</script>
