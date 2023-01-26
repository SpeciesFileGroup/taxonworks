import { reactive, toRefs } from 'vue'
import { sortArrayByArray } from 'helpers/arrays.js'

const state = reactive({
  currentLayout: {},
  layouts: [],
  properties: {},
  includes: {}
})

export function useLayoutConfiguration(Layouts) {
  if (Layouts) {
    const { All } = Layouts

    state.properties = { ...All.properties }
    state.includes = { ...All.includes }
    state.layouts = { ...Layouts }
    Object.assign(state.currentLayout, All)
  }

  const updateLayout = () => {}

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
    updateLayout,
    updatePropertiesPositions
  }
}
