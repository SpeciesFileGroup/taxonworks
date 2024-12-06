<template>
  <div>
    <h2>Select model</h2>
    <ul class="no_bullets">
      <li
        v-for="item in MODEL_TYPES"
        :key="item"
      >
        <label>
          <input
            type="radio"
            name="model"
            :value="item"
            v-model="selected"
          />
          {{ humanize(item) }}
        </label>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { humanize } from '@/helpers/strings'
import { computed } from 'vue'
import {
  OTU,
  ASSERTED_DISTRIBUTION,
  COLLECTION_OBJECT,
  COLLECTING_EVENT,
  TAXON_NAME,
  EXTRACT,
  FIELD_OCCURRENCE
} from '@/constants/index.js'

const MODEL_TYPES = [
  ASSERTED_DISTRIBUTION,
  COLLECTING_EVENT,
  COLLECTION_OBJECT,
  EXTRACT,
  FIELD_OCCURRENCE,
  OTU,
  TAXON_NAME
]

const props = defineProps({
  modelValue: {
    type: String,
    default: undefined
  }
})

const emit = defineEmits(['update:modelValue'])

const selected = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})
</script>
