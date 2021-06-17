export default {
  props: {
    descriptor: {
      type: Object,
      required: true
    },

    modelValue: {
      type: Object,
      default: () => []
    }
  },

  computed: {
    selected: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  }
}
