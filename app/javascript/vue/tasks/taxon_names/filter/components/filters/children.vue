<template>
  <div>
    <h3>Children</h3>
    <ul class="no_bullets">
      <li
        v-for="option in options">
        <label>
          <input
            :value="option.value"
            v-model="optionValue"
            type="radio">
          {{ option.label }}
        </label>
      </li>
    </ul>
  </div>
</template>

<script>

import { URLParamsToJSON } from 'helpers/url/parse.js'

export default {
  props: {
    value: {
      default: undefined
    }
  },
  computed: {
    optionValue: {
      get() {
        return this.value
      },
      set(value) {
        this.$emit('input', value)
      }
    }
  },
  data() {
    return {
      options: [
        {
          label: 'With/out children',
          value: undefined 
        },
        { 
          label: 'With children',
          value: false
        },
        { 
          label: 'Without children',
          value: true
        }
      ]
    }
  },
  mounted () {
    this.optionValue = URLParamsToJSON(location.href).leaves
  }
}
</script>