import { computed, ref } from 'vue'
import { removeEmptyProperties } from '@/helpers/objects.js'
import { ID_PARAM_FOR } from '@/components/radials/filter/constants/idParams.js'
import { QUERY_PARAM } from '@/components/radials/filter/constants/queryParam.js'

export function useRadialBatch({ props, slices, excludeParameters = [] }) {
  const currentSliceName = ref(null)
  const isRadialOpen = ref(false)
  const currentSlice = computed(() => slices[currentSliceName.value])
  const menuOptions = computed(() => {
    const sliceName = Object.keys(slices)

    const items = sliceName.map((type) => ({
      name: type,
      label: type,
      innerPosition: 1.7,
      svgAttributes: {
        class: currentSliceName.value === type ? 'slice active' : 'slice'
      }
    }))

    return {
      width: 440,
      height: 440,
      sliceSize: 140,
      centerSize: 34,
      margin: 2,
      svgAttributes: {
        class: 'svg-radial-menu'
      },
      svgSliceAttributes: {
        fontSize: 11
      },
      slices: items
    }
  })

  const params = computed(() => {
    const parameters = removeEmptyProperties({
      ...props.parameters,
      [ID_PARAM_FOR[props.objectType]]: props.ids
    })

    excludeParameters.forEach((param) => {
      delete parameters[param]
    })

    if (!Object.keys(parameters).length) {
      return {}
    }

    return props.nestedQuery
      ? {
          [QUERY_PARAM[props.objectType]]: parameters
        }
      : parameters
  })

  function selectSlice({ name }) {
    currentSliceName.value = name
  }

  function closeRadialBatch() {
    isRadialOpen.value = false
  }

  function openRadialBatch() {
    isRadialOpen.value = true
  }
  return {
    closeRadialBatch,
    currentSlice,
    isRadialOpen,
    menuOptions,
    openRadialBatch,
    params,
    selectSlice,
    currentSliceName
  }
}
