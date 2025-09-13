import { GetterNames } from '../store/getters/getters.js'
import { MutationNames } from '../store/mutations/mutations.js'
import { User } from '@/routes/endpoints'
import { computed, watch } from 'vue'
import { useStore } from 'vuex'

export function useSortComponents({ keyStorage, componentsSection }) {
  const store = useStore()

  const preferences = computed({
    get() {
      return store.getters[GetterNames.GetPreferences]
    },
    set(value) {
      store.commit(MutationNames.SetPreferences, value)
    }
  })

  const componentsOrder = computed({
    get() {
      return store.getters[GetterNames.GetComponentsOrder][componentsSection]
    },
    set(value) {
      store.commit(
        MutationNames.SetComponentsOrder,
        Object.assign({}, store.getters[GetterNames.GetComponentsOrder], {
          [componentsSection]: value
        })
      )
    }
  })

  watch(
    preferences,
    (newVal) => {
      const storedOrder = newVal.layout[keyStorage]

      if (
        storedOrder &&
        componentsOrder.value.length === storedOrder.length &&
        componentsOrder.value.every((item) => storedOrder.includes(item))
      ) {
        componentsOrder.value = newVal.layout[keyStorage]
      }
    },
    { deep: true }
  )

  function updatePreferences() {
    User.update(preferences.value.id, {
      user: { layout: { [keyStorage]: componentsOrder.value } }
    }).then(({ body }) => {
      preferences.value.layout = body.preferences
      componentsOrder.value = body.preferences.layout[keyStorage]
    })
  }

  return {
    componentsOrder,
    preferences,
    updatePreferences
  }
}
