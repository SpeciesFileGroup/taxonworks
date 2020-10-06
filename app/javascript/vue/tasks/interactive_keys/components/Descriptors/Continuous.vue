<template>
  <div>
    <label class="display-block">
      {{ descriptor.name }} ({{ descriptor.min }}-{{ descriptor.max }} {{ descriptor.default_unit }})
    </label>
    <input type="number">
  </div>
</template>

<script>

import ExtendDescriptor from './shared'

export default {
  mixins: [ExtendDescriptor],
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
      deep: true
    }
  },
  methods: {
    setValue () {
      this.selected[this.descriptor.id] = this.fieldValue
    }
  }
}
</script>
