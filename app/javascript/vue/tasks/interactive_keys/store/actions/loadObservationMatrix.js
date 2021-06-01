import { GetInteractiveKey } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'
import { GetterNames } from '../getters/getters'

export default ({ commit, getters, state }, id) => {
  const filters = getters[GetterNames.GetFilter]
  const otuFilter = (typeof filters?.otu_filter === 'string' && filters.otu_filter.split('|')) || []

  state.settings.isLoading = true
  return GetInteractiveKey(id, filters).then(response => {
    commit(MutationNames.SetObservationMatrix, response.body)

    if (otuFilter.length) {
      const rowIds = state.observationMatrix.remaining
        .filter(row => otuFilter.includes(String(row.object.otu_id)))
        .map(row => row.object.id)

      commit(MutationNames.SetRowFilter, rowIds)
    }
  }).finally(() => {
    state.settings.isLoading = false
  })
}
