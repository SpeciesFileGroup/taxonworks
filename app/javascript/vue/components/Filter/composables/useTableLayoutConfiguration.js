import { reactive, toRefs } from 'vue'
import { User } from '@/routes/endpoints'
import { getCurrentUserId, sortArrayByArray } from '@/helpers'

export function useTableLayoutConfiguration({ model, layouts } = {}) {
  const state = reactive({
    currentLayout: {},
    layouts: {},
    properties: {},
    includes: {}
  })

  const keyStorage = model && `tasks::filters::${model}`

  const initialState = (layouts) => {
    const { All } = layouts

    state.properties = { ...All.properties }
    state.includes = { ...All.includes }
    state.layouts = { ...layouts, Custom: structuredClone(All) }
    Object.assign(state.currentLayout, All)
  }

  const updatePropertiesPositions = (listType) => {
    const usedProperties = state.properties[listType].filter((item) =>
      state.currentLayout.properties[listType].includes(item)
    )

    state.currentLayout.properties[listType] = sortArrayByArray(
      state.currentLayout.properties[listType],
      usedProperties,
      true
    )
  }

  const saveLayoutPreferences = () => {
    const userId = getCurrentUserId()

    if (keyStorage && userId) {
      User.update(userId, {
        user: {
          layout: {
            [keyStorage]: {
              customLayout: state.currentLayout
            }
          }
        }
      })
    }
  }

  const loadCurrentLayout = () => {
    User.preferences().then(({ body }) => {
      const preferences = body.layout[keyStorage]

      if (preferences) {
        state.layouts.Custom = preferences.customLayout
        state.currentLayout = preferences.customLayout

        const subGroup = Object.keys(preferences.customLayout?.properties) || []

        subGroup.forEach((group) => {
          state.properties[group] = sortArrayByArray(
            state.properties[group],
            state.currentLayout.properties[group],
            true
          )
        })
      }
    })
  }

  const resetPreferences = () => {
    initialState(layouts)

    if (keyStorage) {
      const userId = getCurrentUserId()

      User.update(userId, {
        user: {
          layout: {
            [keyStorage]: null
          }
        }
      })
    }
  }

  initialState(layouts)

  if (keyStorage) {
    loadCurrentLayout()
  }

  return {
    ...toRefs(state),
    updatePropertiesPositions,
    saveLayoutPreferences,
    resetPreferences
  }
}
