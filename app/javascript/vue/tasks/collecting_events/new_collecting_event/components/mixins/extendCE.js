export default {
  props: {
    value: {
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
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    },
    collectingEventId () {
      return this.collectingEvent.id
    }
  }
}
