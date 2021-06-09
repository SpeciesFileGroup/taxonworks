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
    value: {
      default: undefined
    }
  },
  computed: {
    optionValue: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },
  mounted () {
    const params = URLParamsToJSON(location.href)
    this.optionValue = params.exact
  }
}
</script>
