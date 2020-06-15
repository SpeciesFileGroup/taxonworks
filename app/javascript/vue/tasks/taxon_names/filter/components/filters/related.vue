<template>
  <label>
    <input
      type="checkbox"
      :disabled="!taxonName.length"
      v-model="optionValue">
    Include descendants
  </label>
</template>

<script>

import { URLParamsToJSON } from 'helpers/url/parse.js'

export default {
  props: {
    value: {
      type: Boolean,
      default: undefined
    },
    taxonName: {
      type: Array,
      required: true
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
  mounted () {
    const params = URLParamsToJSON(location.href)
    this.optionValue = params.descendants
  }
}
</script>
