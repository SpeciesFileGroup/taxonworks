<template>
  <FacetContainer>
    <h3>Target</h3>
    <ul class="no_bullets">
      <li
        v-for="(value, key) in OPTIONS"
        :key="key"
      >
        <label>
          <input
            type="radio"
            :value="value"
            v-model="params.ancestor_id_target"
          >
          {{ key }}
        </label>
      </li>
    </ul>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { computed, onBeforeMount } from 'vue'

const OPTIONS = {
  All: undefined,
  OTU: 'Otu',
  'Collection object': 'CollectionObject'
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
  set: value => emit('update:modelValue', value)
})

onBeforeMount(() => {
  params.value.ancestor_id_target = URLParamsToJSON(location.href).ancestor_id_target
})
</script>
