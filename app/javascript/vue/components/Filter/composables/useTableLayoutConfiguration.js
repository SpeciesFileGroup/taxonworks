import { reactive, toRefs } from 'vue'
import { User } from '@/routes/endpoints'
import { getCurrentUserId } from '@/helpers'

function sortArrayByArray(arr, arrOrder) {
  const setOrden = new Set(arrOrder)

  const sorted = arr
    .filter((item) => setOrden.has(item))
    .sort((a, b) => arrOrder.indexOf(a) - arrOrder.indexOf(b))

  let result = []
  let index = 0

  for (const item of arr) {
    if (setOrden.has(item)) {
      result.push(sorted[index++])
    } else {
      result.push(item)
    }
  }

  return result
}

export function useTableLayoutConfiguration({ model, layouts } = {}) {
  const CURRENT_SCHEMA_DATE = 20250422

  const state = reactive({
    currentLayout: null,
    layouts: {},
    properties: {},
    includes: {}
  })

  const keyStorage = model && `tasks::filters::${model}`

  const initialState = (layouts) => {
    const { All } = structuredClone(layouts)

    state.properties = { ...All.properties }
    state.includes = { ...All.includes }
    state.layouts = { ...layouts, Custom: All }
    state.currentLayout = structuredClone(All)
  }

  const updatePropertiesPositions = (listType) => {
    const usedProperties = state.properties[listType].filter((item) =>
      state.currentLayout.properties[listType].includes(item)
    )

    state.currentLayout.properties[listType] = sortArrayByArray(
      state.currentLayout.properties[listType],
      usedProperties
    )
  }

  // A column dragged in the table: the current layout takes the new order
  // (also shown in the layout selector) and is saved, as when ordered there.
  // @param section [String] e.g. 'collecting_event'
  // @param columns [Array<String>] the section's columns, in the new order
  const reorderLayoutColumns = ({ section, columns }) => {
    state.currentLayout.properties[section] = columns

    if (Array.isArray(state.properties[section])) {
      state.properties[section] = sortArrayByArray(
        state.properties[section],
        columns
      )
    }

    saveLayoutPreferences()
  }

  const saveLayoutPreferences = () => {
    const userId = getCurrentUserId()

    if (keyStorage && userId) {
      User.update(userId, {
        user: {
          layout: {
            [keyStorage]: {
              preferenceSchema: CURRENT_SCHEMA_DATE,
              customLayout: state.currentLayout
            }
          }
        }
      })
    }
  }

  const clearPreferences = async () => {
    if (keyStorage) {
      const userId = getCurrentUserId()

      return User.update(userId, {
        user: {
          layout: {
            [keyStorage]: null
          }
        }
      })
    }
  }

  const forceUpdatePreference = async () => {
    await clearPreferences()
    saveLayoutPreferences()
  }

  const loadCurrentLayout = () => {
    User.preferences().then(({ body }) => {
      const preferences = body.layout[keyStorage]

      if (preferences && preferences.preferenceSchema === CURRENT_SCHEMA_DATE) {
        state.layouts.Custom = preferences.customLayout
        state.currentLayout = preferences.customLayout

        const subGroup = Object.keys(preferences.customLayout?.properties) || []

        subGroup.forEach((group) => {
          if (Array.isArray(state.properties[group])) {
            const newOrder = sortArrayByArray(
              state.properties[group],
              state.currentLayout.properties[group]
            )

            state.properties[group] = newOrder
          }
        })
      }
    })
  }

  const resetPreferences = () => {
    initialState(layouts)
    clearPreferences()
  }

  initialState(layouts)

  if (keyStorage) {
    loadCurrentLayout()
  }

  return {
    ...toRefs(state),
    updatePropertiesPositions,
    reorderLayoutColumns,
    saveLayoutPreferences,
    resetPreferences,
    clearPreferences,
    forceUpdatePreference
  }
}
