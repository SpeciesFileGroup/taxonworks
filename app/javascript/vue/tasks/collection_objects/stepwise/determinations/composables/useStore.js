import { reactive, toRefs } from 'vue'
import { CollectionObject, TaxonDetermination } from 'routes/endpoints'

const state = reactive({
  isLoading: false,
  labels: [],
  collectionObjects: [],
  taxonDetermination: undefined,
  selectedCOIds: [],
  selectedLabel: undefined,
})

export default () => {
  const loadBufferedPage = (page = 1) => {
    const params = {
      count_cutoff: 100,
      per: 10,
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
      ...state.taxonDetermination,
      collection_object_id: state.selectedCOIds
    }

    TaxonDetermination.createBatch({ taxon_determination: params }).then(_ => {
      state.collectionObjects = state.collectionObjects.filter(({ id }) => !state.selectedCOIds.includes(id))
    })
  }

  const setLabel = label => {
    state.selectedLabel = label
  }

  const setTaxonDetermination = determination => {
    state.taxonDetermination = determination
  }

  const loadCollectionObjects = () => {
    const params = {
      buffered_determinations: state.selectedLabel,
      exact_buffered_determinations: true,
      taxon_determinations: false
    }

    state.isLoading = true

    CollectionObject.where(params).then(({ body }) => {
      state.collectionObjects = body
      state.isLoading = false
    })
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