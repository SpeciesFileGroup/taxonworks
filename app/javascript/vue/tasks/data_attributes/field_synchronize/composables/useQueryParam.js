import { ref } from 'vue'
import { QUERY_PARAM } from '@/components/radials/filter/constants/queryParam'
import { URLParamsToJSON } from '@/helpers'

export function useQueryParam() {
  const queryParam = ref(null)
  const queryValue = ref(null)
  const parameters = URLParamsToJSON(window.location.href)

  queryParam.value = Object.keys(parameters).find((param) =>
    Object.values(QUERY_PARAM).includes(param)
  )

  queryValue.value = parameters[queryParam.value]

  return {
    queryParam,
    queryValue
  }
}
