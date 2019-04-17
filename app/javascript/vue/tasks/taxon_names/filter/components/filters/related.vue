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
export default {
  props: {
    value: {
      default: undefined
    },
    taxonName: {
      type: String,
      default: ''
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
