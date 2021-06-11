<template>
  <div>
    <h3>Citations</h3>
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
          label: 'With/out citations',
          value: undefined
        },
        {
          label: 'Without origin citation',
          value: 'without_origin_citation'
        },
        {
          label: 'Without citations',
          value: 'without_citations'
        }
      ]
    }
  },

  mounted () {
    this.optionValue = URLParamsToJSON(location.href).citations
  }
}
</script>
