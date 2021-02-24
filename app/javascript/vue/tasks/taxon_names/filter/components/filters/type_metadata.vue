<template>
  <div>
    <h3>Type metadata</h3>
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
          label: 'With/out metadata',
          value: undefined 
        },
        { 
          label: 'With metadata',
          value: true
        },
        { 
          label: 'Without metadata',
          value: false
        }
      ]
    }
  },
  mounted () {
    this.optionValue = URLParamsToJSON(location.href).type_metadata
  }
}
</script>