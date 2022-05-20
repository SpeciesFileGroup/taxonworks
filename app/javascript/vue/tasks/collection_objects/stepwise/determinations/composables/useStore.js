import { reactive, toRefs } from 'vue'
import { CollectionObject, TaxonDetermination } from 'routes/endpoints'

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
  }
})

export default () => {
  const loadBufferedPage = (page = 1) => {
    const params = {
      ...state.bufferedParams,
      page
    }
    const request = CollectionObject.stepwiseDeterminations(params)

    state.isLoading = true

    request.then(({ body }) => {
      state.labels = body
      state.isLoading = false
    })

    return request
  }

  const createDeterminations = () => {
    const params = {
      taxon_determination: state.taxonDetermination,
      collection_object_id: state.selectedCOIds
    }

    TaxonDetermination.createBatch(params).then(_ => {
      state.collectionObjects = state.collectionObjects.filter(({ id }) => !state.selectedCOIds.includes(id))
      state.selectedCOIds = []
      
      TW.workbench.alert.create('Taxon determinations were successfully created.', 'notice')
    })
  }

  const setLabel = label => {
    state.selectedLabel = label
  }

  const setTaxonDetermination = determination => {
    state.taxonDetermination = determination
  }

  const loadCollectionObjects = page => {
    const params = {
      buffered_determinations: state.selectedLabel,
      exact_buffered_determinations: true,
      taxon_determinations: false,
      per: 500,
      page
    }
    const request = CollectionObject.where(params)

    state.isLoading = true

    request.then(({ body }) => {
      state.collectionObjects = body
      state.isLoading = false
    })

    return request
  }

  return {
    loadBufferedPage,
    loadCollectionObjects,
    createDeterminations,
    setLabel,
    setTaxonDetermination,
    ...toRefs(state)
  }
}