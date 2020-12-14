import { GetterNames } from '../../store/getters/getters'

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
  },
  computed: {
    loadState () {
      return this.$store.getters[GetterNames.GetLoadState]
    }
  }
}
