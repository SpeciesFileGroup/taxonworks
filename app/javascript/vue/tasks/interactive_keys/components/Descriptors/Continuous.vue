<template>
  <div>
    <label>
      <input type="text">
      {{ descriptor.unit }}
    </label>
  </div>
</template>

<script>
export default {
  props: {
    descriptor: {
      type: Object,
      required: true
    },
    value: {
      type: Array,
      default: () => []
    }
  },
  computed: {
    selected: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  }
}
</script>
