import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

import LockComponent from 'components/lock'

export default {
  components: {
    LockComponent
  },
  computed: {
    lock: {
      get () {
        return this.$store.getters[GetterNames.GetLocks]
      },
      set (value) {
        this.$store.commit(MutationNames.SetLocks, value)
      }
    }
  }
}
