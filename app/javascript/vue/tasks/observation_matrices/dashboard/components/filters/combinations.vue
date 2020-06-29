<template>
  <div>
    <h2>Combinations</h2>
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
