<template>
  <div>
    <h3>Precision</h3>
    <label>
      <input
        v-model="optionValue"
        type="checkbox">
      Exact match only
    </label>
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
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  },
  mounted () {
    const params = URLParamsToJSON(location.href)
    this.optionValue = params.exact
  }
}
</script>
