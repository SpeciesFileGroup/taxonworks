import { reactive, toRefs } from 'vue'
import { sortArrayByArray } from 'helpers/arrays.js'

const state = reactive({
  currentLayout: {},
  layouts: [],
  properties: {},
  includes: {}
})

export function useLayoutConfiguration({ properties, includes } = {}) {
  if (properties) {
    const DEFAULT_LAYOUT = {
      name: 'Default',
      properties: { ...properties },
      includes: { ...includes }
    }

    state.properties = { ...properties }
    state.includes = { ...includes }
    state.layouts.push(DEFAULT_LAYOUT)
    Object.assign(state.currentLayout, DEFAULT_LAYOUT)
  }

  const newLayout = (name) => {
    const newLayout = {
      name,
      properties: { ...properties }
    }

    state.layouts.push(newLayout)
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

  return {
    ...toRefs(state),
    newLayout,
    updatePropertiesPositions
  }
}
