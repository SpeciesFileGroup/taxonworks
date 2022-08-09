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
    modelValue: {
      type: Boolean,
      default: undefined
    }
  },

  emits: ['update:modelValue'],

  computed: {
    combination: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  }
}
</script>
