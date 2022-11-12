<template>
  <div>
    <h3>Historical determinations</h3>
    <ul class="no_bullets">
      <li
        v-for="(value, label) in OPTIONS"
        :key="label"
      >
        <label>
          <input
            type="radio"
            :value="value"
            v-model="historicalDetermination"
          >
          {{ label }}
        </label>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'

const OPTIONS = {
  'Only current': undefined,
  'Current and historical': false,
  'Only historical': true
}

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: undefined
  }
})

const emit = defineEmits(['update:modelValue'])

const historicalDetermination = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

historicalDetermination.value = URLParamsToJSON(location.href)?.historical_determinations
</script>
