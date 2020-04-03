<template>
  <div>
    <div class="field">
      <label>Title</label>
      <input
        type="text"
        v-model="source.title">
      <label class="horizontal-left-content">
        <input
          type="checkbox"
          v-model="source.exact_title">
        Exact
      </label>
    </div>
  </div>
</template>

<script>

export default {
  props: {
    value: {
      type: Object,
      default: undefined
    }
  },
  computed: {
    source: {
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
