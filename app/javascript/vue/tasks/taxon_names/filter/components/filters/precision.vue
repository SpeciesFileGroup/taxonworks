<template>
  <div>
    <h2>Precision</h2>
    <label>
      <input
        v-model="optionValue"
        type="checkbox">
      Exact match only
    </label>
  </div>
</template>

<script>
export default {
  props: {
    value: {
      default: undefined
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
}
</script>

<style>

</style>
