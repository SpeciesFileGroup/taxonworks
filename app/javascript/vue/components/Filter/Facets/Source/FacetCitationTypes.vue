<template>
  <FacetContainer>
    <h3>Citations type</h3>
    <ul class="no_bullets">
      <li
        v-for="type in types"
        :key="type"
      >
        <label class="capitalize">
          <input
            type="checkbox"
            :value="type"
            v-model="selectedTypes"
          >
          <span class="capitalize-first-letter">{{ decamelize(type) }}</span>
        </label>
      </li>
    </ul>
  </FacetContainer>
</template>

<script setup>
import { ref, computed } from 'vue'
import { Source } from 'routes/endpoints'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import decamelize from 'helpers/decamelize'
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'

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

const selectedTypes = computed({
  get: () => params.value.citation_object_type || [],
  set: value => { params.value.citation_object_type = value }
})

const types = ref([])

Source.citationTypes().then(response => {
  types.value = response.body
})

const urlParams = URLParamsToJSON(location.href)

params.value.citation_object_type = (urlParams.citation_object_type ||= [])
</script>
