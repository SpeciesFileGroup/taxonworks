import { computed } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'

export default () => {
  const store = useStore()
  const settings = computed({
    get () {
      return store.getters[GetterNames.GetSettings]
    },
    set (value) {
      store.commit(MutationNames.SetSettings, value)
    }
  })

  return settings
}