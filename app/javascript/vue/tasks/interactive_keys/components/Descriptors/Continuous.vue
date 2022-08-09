<template>
  <descriptor-container :descriptor="descriptor">
    <template #title>
      {{ descriptor.name }} ({{ descriptor.min }}-{{ descriptor.max }} {{ descriptor.default_unit }})
    </template>
    <input
      v-model="fieldValue"
      @blur="setValue"
      type="text">
  </descriptor-container>
</template>

<script>

import ExtendDescriptor from './shared.js'

export default {
  mixins: [ExtendDescriptor],

  data () {
    return {
      fieldValue: undefined
    }
  },

  watch: {
    modelValue: {
      handler (newVal) {
        if (newVal[this.descriptor.id] !== this.fieldValue) {
          this.fieldValue = newVal[this.descriptor.id]
        }
      },
      deep: true,
      immediate: true
    }
  },
  methods: {
    setValue () {
      this.selected[this.descriptor.id] = this.fieldValue
    }
  }
}
</script>
