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
    value: {
      type: [String, Number],
      default: undefined
    }
  },

  computed: {
    identifier: {
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
