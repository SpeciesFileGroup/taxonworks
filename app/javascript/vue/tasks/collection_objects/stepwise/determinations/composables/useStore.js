import { reactive, toRefs } from 'vue'
import { CollectionObject, TaxonDetermination } from 'routes/endpoints'
import getPagination from 'helpers/getPagination'

const state = reactive({
  isLoading: false,
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

const decrementCount = () => {
  const { labels } = state

  labels[0].count_buffered = 0
}

export default () => {

  const actions = {
    createDeterminations () {
      const params = {
        taxon_determination: state.taxonDetermination,
        collection_object_id: state.selectedCOIds
      }

      TaxonDetermination.createBatch(params).then(_ => {
        state.collectionObjects = state.collectionObjects.filter(({ id }) => !state.selectedCOIds.includes(id))
        state.selectedCOIds = []
        loadBufferedPage(1)
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
        decrementCount()
      })

      return request
    },
  
    loadCollectionObjects (page) {
      const params = {
        buffered_determinations: state.selectedLabel,
        exact_buffered_determinations: true,
        taxon_determinations: false,
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
    },

    setTaxonDetermination (determination)  {
      state.taxonDetermination = determination
    },
  }

  const getters = {
    getPages: () => state.pagination
  }

  return {
    ...actions,
    ...getters,
    ...toRefs(state)
  }
}