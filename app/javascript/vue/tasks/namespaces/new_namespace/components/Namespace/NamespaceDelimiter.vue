<template>
  <div class="field">
    <label>Delimiter</label>
    <ul class="no_bullets">
      <li
        v-for="(value, key) in Types"
        :key="value">
        <label>
          <input
            type="radio"
            :value="value"
            v-model="delimiter">
          {{ key }}
        </label>
      </li>
      <li>
        <label>
          <input
            type="radio"
            :value="undefined"
            :checked="isCustomDelimiter"
            @click="delimiter = undefined"
          >
          Custom character
        </label>
      </li>
    </ul>
  </div>
  <div
    v-if="isCustomDelimiter"
    class="field label-above">
    <label>Custom character</label>
    <input
      type="text"
      maxlength="1"
      v-model="delimiter">
  </div>
</template>

<script setup>

import { computed, defineProps, defineEmits } from 'vue'
import Types from '../../const/types'

const props = defineProps({
  modelValue: {
    type: String,
    default: undefined
  }
})

const emit = defineEmits(['update:modelValue'])

const delimiter = computed({
  get () {
    return props.modelValue
  },
  set (value) {
    emit('update:modelValue', value)
  }
})

const isCustomDelimiter = computed(() => !Object.values(Types).includes(delimiter.value) || delimiter.value === undefined)

</script>
