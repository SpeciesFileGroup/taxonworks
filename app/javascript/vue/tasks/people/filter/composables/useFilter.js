import { reactive, toRefs } from 'vue'
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
    state.parameters = params
    state.isLoading = true

    service.where({
      per: state.per,
      ...params
    }).then((response) => {
      state.list = response.body
      state.isLoading = false
      state.pagination = getPagination(response)
      state.urlRequest = response.request.url
      setRequestUrl(response.request)
    })
  }

  const setRequestUrl = request => {
    const urlParams = new URLSearchParams(request.responseURL.split('?')[1])

    state.urlRequest = request.responseURL
    history.pushState(null, null, `${window.location.pathname}?${urlParams.toString()}`)
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
    state.urlRequest = ''
    history.pushState(null, null, `${window.location.pathname}`)
  }

  return {
    ...toRefs(state),
    makeFilterRequest,
    loadPage,
    resetFilter
  }
}
