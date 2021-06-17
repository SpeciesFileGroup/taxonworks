export default {
  props: {
    modelValue: {
      type: Object,
      required: true
    },

    componentsOrder: {
      type: Object,
      default: () => {}
    }
  },

  computed: {
    collectingEvent: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    },

    collectingEventId () {
      return this.collectingEvent.id
    }
  }
}
