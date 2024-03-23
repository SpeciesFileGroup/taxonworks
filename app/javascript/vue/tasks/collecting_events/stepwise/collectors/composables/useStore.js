import { reactive, toRefs, computed } from 'vue'
import { CollectingEvent } from '@/routes/endpoints'
import getPagination from '@/helpers/getPagination'

const state = reactive({
  isLoading: false,
  isCreating: false,
  verbatimCollectorFields: [],  // list of distinct verbatim collector strings with size of each group
  collectingEvents: [],   // list of collecting events with same verbatim collector string
  collectorRoleList: [],  // collectors to add to selected CEs
  selectedCEIds: [],
  selectedCollectorString: undefined,
  verbatimParams: {
    count_cutoff: 100,
    per: 10
  },
  collectingEventParams: {
    per: 500
  },
  pagination: {
    stepwise: {},
    collectingEvents: {}
  }
})

const updateVerbatimTable = (count) => {
  const { verbatimCollectorFields } = state
  const index = verbatimCollectorFields.findIndex(
    (collectorGroup) => collectorGroup.verbatim_collectors === state.selectedCollectorString
  )
  const collectorGroup = verbatimCollectorFields[index]
  const newCount = collectorGroup.count_collectors - count

  if (newCount > 0) {
    collectorGroup.count_collectors = newCount
    state.pagination.collectingEvents.total -= count
  } else {
    verbatimCollectorFields.splice(index, 1)
  }

  if (!verbatimCollectorFields.length) {
    actions.loadVerbatimPage(1)
  }
}

const actions = {
  // perform the batch update
  createCollectors() {
    const params = {
      collecting_event: {
        roles_attributes:
        // remove position so roles are appended to end of list
          state.collectorRoleList.map(({ position, ...rest }) => rest)
      },
      collecting_event_query:
        { collecting_event_id: state.selectedCEIds }
    }

    state.isCreating = true

    CollectingEvent.batchUpdate(params).then((_) => {
      updateVerbatimTable(state.selectedCEIds.length)
      state.collectingEvents = state.collectingEvents.filter(
        ({ id }) => !state.selectedCEIds.includes(id)
      )
      state.selectedCEIds = []
      state.isCreating = false
      TW.workbench.alert.create(
        'Collectors successfully set.',
        'notice'
      )
    })
  },

  loadVerbatimPage: (page = 1) => {
    const params = {
      ...state.verbatimParams,
      page
    }
    const request = CollectingEvent.stepwiseCollectors(params)

    state.isLoading = true

    request.then((response) => {
      state.verbatimCollectorFields = response.body
      state.pagination.stepwise = getPagination(response)
      state.isLoading = false
    })

    return request
  },

  loadCollectingEvents(page) {
    const params = {
      verbatim_collectors: state.selectedCollectorString,
      exact_verbatim_collector: true,
      collectors: false,
      per: state.collectingEventParams.per,
      page
    }
    const request = CollectingEvent.where(params)

    state.isLoading = true

    request.then((response) => {
      state.collectingEvents = response.body
      state.pagination.collectingEvents = getPagination(response)
      state.isLoading = false
    })

    return request
  },

  setVerbatimCollectorString(collectorString) {
    state.selectedCollectorString = collectorString
    state.collectingEvents = []
    state.selectedCEIds = []
  }
}

const getters = {
  getPages: () => state.pagination,

  ghostCount: computed(() => {
    const countCollectors = state.verbatimCollectorFields.find(
      (collectorGroup) => collectorGroup.verbatim_collectors === state.selectedCollectorString
    )?.count_collectors

    return state.pagination.collectingEvents.total - countCollectors
  })
}

export default () => {
  return {
    ...actions,
    ...getters,
    ...toRefs(state)
  }
}
