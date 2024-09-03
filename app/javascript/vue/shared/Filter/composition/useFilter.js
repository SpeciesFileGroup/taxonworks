import { reactive, toRefs, onBeforeMount } from 'vue'
import getPagination from '@/helpers/getPagination'
import qs from 'qs'

export default function (service, { listParser, initParameters } = {}) {
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

  const makeFilterRequest = (params = state.parameters) => {
    const payload = removeEmptyParameters({
      ...params
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

        state.selectedIds = []
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
    const urlParameters = {
      ...qs.parse(location.search, { ignoreQueryPrefix: true }),
      ...JSON.parse(sessionStorage.getItem('filterQuery'))
    }

    Object.assign(state.parameters, urlParameters)

    sessionStorage.removeItem('filterQuery')

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
    resetFilter
  }
}
