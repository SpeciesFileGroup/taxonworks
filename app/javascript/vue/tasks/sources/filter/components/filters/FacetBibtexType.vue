<template>
  <div>
    <h3>BybTeX type</h3>
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
            >
            {{ type }}
          </label>
        </li>
      </ul>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'

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
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['update:modelValue'])

const selectedTypes = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

const urlParams = URLParamsToJSON(location.href)

selectedTypes.value = urlParams.bibtex_type || []
</script>
