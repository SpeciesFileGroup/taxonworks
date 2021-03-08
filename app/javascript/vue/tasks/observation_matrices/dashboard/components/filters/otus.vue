<template>
  <div>
    <h3>Otu</h3>
    <label>
      <input
        type="checkbox"
        v-model="validity">
      Linked to valid only
    </label>
  </div>
</template>

<script>

export default {
  props: {
    value: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    validity: {
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
