import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

export default {
  computed: {
    extract: {
      get () {
        return this.$store.getters[GetterNames.GetExtract]
      },
      set (value) {
        this.$store.commit(MutationNames.SetExtract, value)
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
