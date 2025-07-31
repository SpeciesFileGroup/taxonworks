<template>
  <FacetContainer>
    <h3>BibTeX type</h3>
    <div class="field">
      <ul class="no_bullets">
        <li
          v-for="type in TYPES"
          :key="type"
        >
          <label class="capitalize">
            <input
              type="checkbox"
              :value="type"
              v-model="selectedTypes"
            />
            {{ type }}
          </label>
        </li>
      </ul>
    </div>
  </FacetContainer>
</template>

<script setup>
import { computed } from 'vue'
import { URLParamsToJSON } from '@/helpers/url/parse.js'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'

const TYPES = [
  'article',
  'book',
  'booklet',
  'conference',
  'inbook',
  'incollection',
  'inproceedings',
  'manual',
  'mastersthesis',
  'misc',
  'phdthesis',
  'proceedings',
  'techreport',
  'unpublished'
]

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
  get: () => params.value.bibtex_type || [],
  set: (value) => {
    params.value.bibtex_type = value
  }
})

const urlParams = URLParamsToJSON(location.href)

selectedTypes.value = urlParams.bibtex_type || []
</script>
