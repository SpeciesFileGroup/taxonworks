import { reactive, toRefs } from 'vue'
import { CollectionObject, TaxonDetermination } from 'routes/endpoints'
import getPagination from 'helpers/getPagination'

const state = reactive({
  isLoading: false,
  isCreating: false,
  labels: [],
  collectionObjects: [],
  taxonDetermination: undefined,
  selectedCOIds: [],
  selectedLabel: undefined,
  bufferedParams: {
    count_cutoff: 100,
    per: 10
  },
  pagination: {
    stepwise: {},
    collectionObjects: {}
  }
})

const updateBufferedTable = count => {
  const { labels } = state
  const index = labels.findIndex(label => label.buffered_determinations === state.selectedLabel)
  const label = labels[index]
  const newCount = label.count_buffered - count

  if (newCount) {
    label.count_buffered = newCount
  } else {
    labels.splice(index, 1)
  }

  if (!labels.length) {
    actions.loadBufferedPage(1)
  }
}

const actions = {
  createDeterminations () {
    const params = {
      taxon_determination: state.taxonDetermination,
      collection_object_id: state.selectedCOIds
    }

    state.isCreating = true

    TaxonDetermination.createBatch(params).then(_ => {
      updateBufferedTable(state.selectedCOIds.length)
      state.collectionObjects = state.collectionObjects.filter(({ id }) => !state.selectedCOIds.includes(id))
      state.selectedCOIds = []
      state.isCreating = false
      TW.workbench.alert.create('Taxon determinations were successfully created.', 'notice')
    })
  },

  loadBufferedPage: (page = 1) => {
    const params = {
      ...state.bufferedParams,
      page
    }
    const request = CollectionObject.stepwiseDeterminations(params)

    state.isLoading = true

    request.then(response => {
      state.labels = response.body
      state.pagination.stepwise = getPagination(response)
      state.isLoading = false
    })

    return request
  },

  loadCollectionObjects (page) {
    const params = {
      buffered_determinations: state.selectedLabel,
      exact_buffered_determinations: true,
      taxon_determinations: false,
      extend: ['taxon_determination_images'],
      per: 500,
      page
    }
    const request = CollectionObject.where(params)

    state.isLoading = true

    request.then(response => {
      state.collectionObjects = response.body
      state.pagination.collectionObjects = getPagination(response)
      state.isLoading = false
    })

    return request
  },

  setLabel (label) {
    state.selectedLabel = label
    state.collectionObjects = []
    state.selectedCOIds = []
  },

  setTaxonDetermination (determination) {
    state.taxonDetermination = determination
  }
}

const getters = {
  getPages: () => state.pagination
}

export default () => {
  return {
    ...actions,
    ...getters,
    ...toRefs(state)
  }
}
