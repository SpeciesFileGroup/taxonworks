<template>
  <div>
    <h3>Name type</h3>
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
    modelValue: {
      type: String,
      default: undefined
    }
  },

  emits: ['update:modelValue'],

  computed: {
    optionValue: {
      get() {
        return this.modelValue
      },
      set(value) {
        this.$emit('update:modelValue', value)
      }
    }
  },

  data () {
    return {
      options: [
        {
          label: 'Protonym',
          value: 'Protonym'
        },
        {
          label: 'Combination',
          value: 'Combination'
        },
        {
          label: 'Hybrid',
          value: 'Hybrid'
        }
      ]
    }
  },

  mounted () {
    this.optionValue = URLParamsToJSON(location.href).taxon_name_type
  }
}
</script>