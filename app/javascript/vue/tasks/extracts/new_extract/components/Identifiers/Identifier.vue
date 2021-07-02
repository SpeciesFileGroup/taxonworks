<template>
  <div class="label-above full_width">
    <label>Identifier</label>
    <input
      class="full_width"
      v-model="identifier"
      type="text"
    >
  </div>
</template>

<script>
export default {
  props: {
    modelValue: {
      type: [String, Number],
      default: undefined
    }
  },

  emits: ['update:modelValue'],

  computed: {
    identifier: {
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
