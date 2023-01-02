import { reactive, toRefs } from 'vue'
import qs from 'qs'
import getPagination from 'helpers/getPagination'

export default function (service) {
  const state = reactive({
    append: false,
    parameters: {},
    per: 500,
    pagination: undefined,
    list: [],
    isLoading: false,
    urlRequest: ''
  })

  const makeFilterRequest = (params = state.parameters) => {
    const payload = {
      per: state.per,
      ...params
    }

    state.isLoading = true

    return service.filter(payload).then(response => {
      if (state.append) {
        let concat = response.body.concat(state.list)

        concat = concat.filter((item, index, self) =>
          index === self.findIndex((i) => (
            i.id === item.id
          ))
        )

        state.list = concat
      } else {
        state.list = response.body
      }

      state.pagination = getPagination(response)
      state.urlRequest = response.request.url
      setRequestUrl(response.request.responseURL, payload)
    }).finally(() => {
      state.isLoading = false
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
    state.parameters = {}
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
