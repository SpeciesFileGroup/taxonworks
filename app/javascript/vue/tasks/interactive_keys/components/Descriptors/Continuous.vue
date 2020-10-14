<template>
  <div>
    <label class="display-block">
      {{ descriptor.name }} ({{ descriptor.min }}-{{ descriptor.max }} {{ descriptor.default_unit }})
    </label>
    <input
      v-model="fieldValue"
      @blur="setValue"
      type="text">
    <span
      v-if="!validRange"
      class="red">Number is out of range.</span>
  </div>
</template>

<script>

import ExtendDescriptor from './shared.js'

export default {
  mixins: [ExtendDescriptor],
  computed: {
    validRange () {
      return this.fieldValue ? this.fieldValue.match(/[+-]?\d+(\.\d+)?/g).map(numberString => Math.abs(Number(numberString)))
        .every(number => number <= this.descriptor.max && number >= this.descriptor.min) : true
    }
  },
  data () {
    return {
      fieldValue: undefined
    }
  },
  watch: {
    value: {
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
      if (!this.validRange) return
      this.$set(this.selected, this.descriptor.id, this.fieldValue)
    }
  }
}
</script>
