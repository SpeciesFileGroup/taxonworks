export default {
  props: {
    status: {
      type: String,
      default: 'unknown'
    },
    title: {
      type: String,
      default: undefined
    },
    otu: {
      type: Object,
      required: true
    }
  }
}
