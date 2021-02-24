<template>
  <div>
    <h3>Combinations</h3>
    <label>
      <input
        type="checkbox"
        v-model="combination">
      Includes
    </label>
  </div>
</template>

<script>

export default {
  props: {
    value: {
      type: Boolean,
      default: undefined
    }
  },
  computed: {
    combination: {
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
