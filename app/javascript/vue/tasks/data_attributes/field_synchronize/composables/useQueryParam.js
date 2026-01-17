import { ref } from 'vue'
import { QUERY_PARAM } from '@/components/radials/filter/constants/queryParam'
import qs from 'qs'
import { LinkerStorage } from '@/shared/Filter/utils'

export function useQueryParam() {
  const queryParam = ref(null)
  const queryValue = ref(null)
  const parameters = {
    ...qs.parse(window.location.search, {
      ignoreQueryPrefix: true,
      arrayLimit: 2000
    }),
    ...LinkerStorage.getParameters()
  }

  console.log(parameters)

  LinkerStorage.removeParameters()

  queryParam.value = Object.keys(parameters).find((param) =>
    Object.values(QUERY_PARAM).includes(param)
  )

  queryValue.value = parameters[queryParam.value]

  return {
    parameters,
    queryParam,
    queryValue
  }
}
