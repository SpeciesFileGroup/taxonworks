<template>
  <button
    class="normal-input button button-submit"
    type="button">Create</button>
</template>
<script>

export default {
  props: {
    descriptor: {
      type: Object
    }
  },
  methods: {
    saveDescriptor() {
      this.$emit('save')
    }
  }
}
</script>