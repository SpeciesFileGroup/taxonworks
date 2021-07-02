<template>
  <div>
    <span
      @click="expand = !expand"
      :data-icon="icon"
    />
  </div>
</template>
<script>

export default {
  props: {
    modelValue: {
      type: Boolean,
      default: false
    }
  },

  emits: ['update:modelValue'],

  computed: {
    expand: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    },

    icon () {
      return this.expand ? 'contract' : 'expand'
    }
  }
}
</script>
