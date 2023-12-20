import { GetterNames } from '../../../store/getters/getters'
import { MutationNames } from '../../../store/mutations/mutations'
import { ActionNames } from '../../../store/actions/actions'

export default {
  computed: {
    collectingEvent: {
      get() {
        return this.$store.getters[GetterNames.GetCollectingEvent]
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectingEvent, value)
      }
    }
  },
  methods: {
    updateChange() {
      this.$store.dispatch(ActionNames.UpdateCEChange)
    }
  }
}
