import { reactive, toRefs } from 'vue'
import qs from 'qs'
import getPagination from 'helpers/getPagination'

export default function (service) {
  const state = reactive({
    parameters: {},
    per: 500,
    pagination: undefined,
    list: [],
    isLoading: false,
    urlRequest: ''
  })

  const makeFilterRequest = params => {
    const payload = {
      per: state.per,
      ...params
    }

    state.parameters = params
    state.isLoading = true

    service.filter(payload).then(response => {
      state.list = response.body
      state.isLoading = false
      state.pagination = getPagination(response)
      state.urlRequest = response.request.url
      setRequestUrl(response.request.responseURL, payload)
    })
  }

  const setRequestUrl = (url, params) => {
    const urlParams = qs.stringify(params, { arrayFormat: 'brackets' })

    state.urlRequest = [url, urlParams].join('?')
    history.pushState(null, null, `${window.location.pathname}?${urlParams}`)
  }

  const loadPage = params => {
    makeFilterRequest({
      ...state.parameters,
      ...params
    })
  }

  const resetFilter = () => {
    state.list = []
    state.isLoading = false
    history.pushState(null, null, `${window.location.pathname}`)
  }

  return {
    ...toRefs(state),
    makeFilterRequest,
    loadPage,
    resetFilter
  }
}
