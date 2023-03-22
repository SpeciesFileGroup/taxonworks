import { reactive } from 'vue'

export const useParameters = (params) => {
  const parameters = reactive(params)

  return {
    parameters
  }
}
