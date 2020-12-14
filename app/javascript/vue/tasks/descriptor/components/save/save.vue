<template>
  <button
    @click="saveDescriptor"
    class="normal-input button button-submit"
    type="button"
    :disabled="validate">
    {{ descriptor.id ? 'Update' : 'Create' }}
  </button>
</template>
<script>

export default {
  props: {
    descriptor: {
      type: Object,
      required: true
    }
  },
  computed: {
    validate () {
      return !this.descriptor.name
    }
  },
  methods: {
    saveDescriptor () {
      this.$emit('save')
    }
  }
}
</script>