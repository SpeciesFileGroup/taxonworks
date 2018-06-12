<template>
  <button
    @click="saveDescriptor"
    class="normal-input button button-submit"
    type="button">{{ descriptor['id'] ? 'Update' : 'Create' }}</button>
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