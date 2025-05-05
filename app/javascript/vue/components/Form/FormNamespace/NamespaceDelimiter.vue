<template>
  <div>
    <div
      v-help="help.delimiter"
      class="field"
    >
      <label>Delimiter</label>
      <ul class="no_bullets">
        <li
          v-for="(value, key) in Types"
          :key="value"
        >
          <label>
            <input
              type="radio"
              :value="value"
              v-model="delimiter"
            />
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
            />
            Custom character
          </label>
        </li>
      </ul>
    </div>
    <div
      v-if="isCustomDelimiter"
      class="field label-above"
    >
      <label>Custom character</label>
      <input
        type="text"
        maxlength="1"
        v-model="delimiter"
      />
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { vHelp } from '@/directives'
import help from './constants/help'

const Types = {
  'Single whitespace': null,
  None: 'NONE'
}

const delimiter = defineModel({
  type: String,
  default: undefined
})

const isCustomDelimiter = computed(
  () =>
    !Object.values(Types).includes(delimiter.value) ||
    delimiter.value === undefined
)
</script>
