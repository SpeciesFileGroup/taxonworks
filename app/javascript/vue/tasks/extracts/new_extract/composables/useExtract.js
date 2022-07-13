import { computed } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'

export default () => {
  const store = useStore()
  const extract = computed({
    get () {
      return store.getters[GetterNames.GetExtract]
    },
    set (value) {
      store.commit(MutationNames.SetExtract, value)
    }
  })

  return extract
}
