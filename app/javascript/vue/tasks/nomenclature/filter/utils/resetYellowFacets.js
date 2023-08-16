import { computed } from 'vue'

export function useYellowFacetCheckbox(props, emit, param) {
  const parameters = ['validify', 'combinationify', 'synonymify']

  const params = computed({
    get: () => props.modelValue,
    set: (value) => {
      emit('update:modelValue', value)
    }
  })

  const inputValue = computed({
    get: () => props.modelValue[param],
    set: (value) => {
      const unsetParameters = Object.fromEntries(parameters.map((p) => [p]))

      if (value) {
        Object.assign(params.value, unsetParameters, { [param]: value })
      }
    }
  })

  return inputValue
}
