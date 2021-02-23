import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

export default {
  props: {
    value: {
      type: Object,
      required: true
    }
  },
  computed: {
    extract: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    },

    settings: {
      get () {
        return this.$store.getters[GetterNames.GetSettings]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSettings, value)
      }
    }
  }
}
