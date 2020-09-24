export default {
  props: {
    descriptor: {
      type: Object,
      required: true
    },
    value: {
      type: Object,
      default: () => []
    }
  },
  computed: {
    selected: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  }
}
