import { computed, reactive, toRefs, onBeforeMount } from 'vue'
import {
  STORAGE_FILTER_QUERY_STATE_PARAMETER,
  STORAGE_FILTER_QUERY_KEY
} from '@/constants'
import { getParametersFromSession, fetchSortableColumns } from '../utils'
import useFilterView from './useFilterView.js'
import { sortArrayByReference } from '@/helpers'
import getPagination from '@/helpers/getPagination'
import qs from 'qs'

// @param initParameters [Object] sent with every request (e.g. extend,
//   exclude), never taken from the URL
// @param defaultParameters [Object] the parameters to start from when the
//   URL has none, and after a reset
// @param sortableColumnsResource [String] the backend resource whose sort
//   keys gate the table's sort, e.g. 'collection_objects'
// @param objectType [String] when given, also sets up the table's view
//   state (sort, saved default), see useFilterView
export default function (
  service,
  {
    listParser,
    initParameters = {},
    defaultParameters = {},
    sortableColumnsResource,
    objectType
  } = {}
) {
  const DEFAULT_PER = 50
  const DEFAULT_PARAMETERS = {
    paginate: true
  }
  const state = reactive({
    append: false,
    parameters: {
      per: DEFAULT_PER
    },
    pagination: undefined,
    selectedIds: [],
    list: [],
    isLoading: false,
    initParameters,
    urlRequest: '',
    sortableKeys: null, // null = not yet loaded / not applicable; array = loaded
    maxSortKeys: null // null = no limit known
  })

  // Only the latest request's response is shown: an earlier one can arrive
  // later (e.g. a refetch for a new sort while the first search runs).
  let latestRequest = 0

  const sortedSelectedIds = computed(() =>
    sortArrayByReference({
      list: state.selectedIds,
      reference: state.list,
      getListValue: (id) => id,
      getReferenceValue: (item) => item.id
    })
  )

  // @param append [Boolean] add to the list rather than replace it;
  //   defaults to the append toggle
  const makeFilterRequest = (
    params = state.parameters,
    { append = state.append } = {}
  ) => {
    const payload = removeEmptyParameters({
      ...state.initParameters,
      ...params,
      ...DEFAULT_PARAMETERS
    })
    const request = ++latestRequest

    state.isLoading = true

    return service
      .filter(payload)
      .then(async (response) => {
        if (request !== latestRequest) return

        const result = listParser
          ? await listParser(response.body, { parameters: state.parameters })
          : response.body

        if (request !== latestRequest) return

        if (append) {
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
        if (request === latestRequest) state.isLoading = false
      })
  }

  const setRequestUrl = (url, params) => {
    const urlParams = qs.stringify(params, { arrayFormat: 'brackets' })

    state.urlRequest = [url, urlParams].join('?')
    // Keep the hash: it holds the table's view state (freeze/hide/order).
    history.pushState(
      null,
      null,
      `${window.location.pathname}?${urlParams}${window.location.hash}`
    )
  }

  const removeEmptyParameters = (params) => {
    const cleanedParameters = { ...params }

    for (const key in params) {
      const value = params[key]

      // An empty sort is an explicitly cleared one, see useSortKeys.
      if (key === 'sort' && value === '') continue

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
      ...params
    })
  }

  const resetFilter = () => {
    // Drops any response still on its way.
    latestRequest++
    state.parameters = {
      per: state.parameters.per ?? DEFAULT_PER,
      ...defaultParameters
    }
    state.list = []
    state.isLoading = false
    state.urlRequest = ''
    state.pagination = undefined
    state.selectedIds = []
    history.pushState(null, null, `${window.location.pathname}${window.location.hash}`)
  }

  onBeforeMount(() => {
    const {
      [STORAGE_FILTER_QUERY_STATE_PARAMETER]: stateId,
      ...urlParameters
    } = qs.parse(location.search, { ignoreQueryPrefix: true, arrayLimit: 2000 })

    Object.assign(urlParameters, getParametersFromSession(stateId))

    const exclude = Object.keys({
      ...state.initParameters,
      ...DEFAULT_PARAMETERS
    })

    exclude.forEach((param) => {
      delete urlParameters[param]
    })

    if (!Object.keys(urlParameters).length) {
      Object.assign(state.parameters, defaultParameters)
    }

    Object.assign(state.parameters, urlParameters)

    localStorage.removeItem(STORAGE_FILTER_QUERY_KEY)

    if (sortableColumnsResource) {
      fetchSortableColumns(sortableColumnsResource).then((result) => {
        if (!result) return
        state.sortableKeys = result.columns
        state.maxSortKeys = result.maxSortKeys
      })
    }

    if (Object.keys(urlParameters).length) {
      makeFilterRequest({ ...state.parameters })
    }
  })

  const refs = toRefs(state)

  const view = objectType
    ? useFilterView({
        parameters: refs.parameters,
        makeFilterRequest,
        objectType,
        sortableKeys: refs.sortableKeys,
        maxSortKeys: refs.maxSortKeys
      })
    : {}

  return {
    ...refs,
    ...view,
    makeFilterRequest,
    loadPage,
    resetFilter,
    sortedSelectedIds
  }
}
