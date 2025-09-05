import { computed, reactive, toRefs, onBeforeMount } from 'vue'
import {
  STORAGE_FILTER_QUERY_STATE_PARAMETER,
  STORAGE_FILTER_QUERY_KEY
} from '@/constants'
import { getParametersFromSession } from '../utils'
import { sortArrayByReference } from '@/helpers'
import getPagination from '@/helpers/getPagination'
import qs from 'qs'

export default function (service, { listParser, initParameters = {} } = {}) {
  const DEFAULT_PARAMETERS = {
    paginate: true
  }
  const state = reactive({
    append: false,
    parameters: {
      per: 50
    },
    pagination: undefined,
    selectedIds: [],
    list: [],
    isLoading: false,
    initParameters,
    urlRequest: ''
  })

  const sortedSelectedIds = computed(() =>
    sortArrayByReference({
      list: state.selectedIds,
      reference: state.list,
      getListValue: (id) => id,
      getReferenceValue: (item) => item.id
    })
  )

  const makeFilterRequest = (params = state.parameters) => {
    const payload = removeEmptyParameters({
      ...params,
      ...DEFAULT_PARAMETERS
    })

    state.isLoading = true

    return service
      .filter(payload)
      .then(async (response) => {
        const result = listParser
          ? await listParser(response.body, { parameters: state.parameters })
          : response.body

        if (state.append) {
          let concat = result.concat(state.list)

          concat = concat.filter(
            (item, index, self) =>
              index === self.findIndex((i) => i.id === item.id)
          )

          state.list = concat
        } else {
          state.list = result
        }

        if (Array.isArray(state.list)) {
          const idSet = new Set(state.list.map((item) => item.id))

          state.selectedIds = state.selectedIds.filter((id) => idSet.has(id))
        }

        state.pagination = getPagination(response)
        state.urlRequest = response.request.url
        setRequestUrl(response.request.responseURL, payload)
        sessionStorage.setItem('totalFilterResult', state.pagination.total)
      })
      .catch(() => {})
      .finally(() => {
        state.isLoading = false
      })
  }

  const setRequestUrl = (url, params) => {
    const urlParams = qs.stringify(params, { arrayFormat: 'brackets' })

    state.urlRequest = [url, urlParams].join('?')
    history.pushState(null, null, `${window.location.pathname}?${urlParams}`)
  }

  const removeEmptyParameters = (params) => {
    const cleanedParameters = { ...params }

    for (const key in params) {
      const value = params[key]

      if (
        value === undefined ||
        value === '' ||
        (Array.isArray(value) && !value.length)
      ) {
        delete cleanedParameters[key]
      }
    }

    return cleanedParameters
  }

  const loadPage = (params) => {
    state.parameters.page = params.page
    state.selectedIds = []

    makeFilterRequest({
      ...state.parameters,
      ...state.initParameters,
      ...params
    })
  }

  const resetFilter = () => {
    state.parameters = { per: 50 }
    state.list = []
    state.isLoading = false
    state.urlRequest = ''
    state.pagination = undefined
    state.selectedIds = []
    history.pushState(null, null, `${window.location.pathname}`)
  }

  onBeforeMount(() => {
    const {
      [STORAGE_FILTER_QUERY_STATE_PARAMETER]: stateId,
      ...urlParameters
    } = qs.parse(location.search, { ignoreQueryPrefix: true })

    Object.assign(urlParameters, getParametersFromSession(stateId))

    const exclude = Object.keys({
      ...state.initParameters,
      ...DEFAULT_PARAMETERS
    })

    exclude.forEach((param) => {
      delete urlParameters[param]
    })

    Object.assign(state.parameters, urlParameters)

    localStorage.removeItem(STORAGE_FILTER_QUERY_KEY)

    if (Object.keys(urlParameters).length) {
      makeFilterRequest({
        ...state.parameters,
        ...initParameters
      })
    }
  })

  return {
    ...toRefs(state),
    makeFilterRequest,
    loadPage,
    resetFilter,
    sortedSelectedIds
  }
}
