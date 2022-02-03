import { reactive, toRefs } from 'vue'
import getPagination from 'helpers/getPagination'

export default function (service) {
  const state = reactive({
    parameters: {},
    per: 500,
    pagination: undefined,
    list: [],
    isLoading: false
  })

  const makeFilterRequest = params => {
    state.parameters = params
    state.isLoading = true

    service.where(params).then((response) => {
      state.list = response.body
      state.isLoading = false
      state.pagination = getPagination(response)
    })
  }

  const loadPage = page => {
    service.where({
      ...state.parameters,
      page
    })
  }

  const resetFilter = () => {
    state.list = []
    state.isLoading = false
  }

  return {
    ...toRefs(state),
    makeFilterRequest,
    loadPage,
    resetFilter
  }
}