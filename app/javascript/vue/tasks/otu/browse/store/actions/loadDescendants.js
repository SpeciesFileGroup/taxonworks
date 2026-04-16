import { MutationNames } from '../mutations/mutations'
import { TaxonName } from '@/routes/endpoints'

const MAX_PER_CALL = 50

export default ({ commit, state }, otu) => {
  if (!otu.taxon_name_id) return

  const params = {
    taxon_name_id: [otu.taxon_name_id],
    descendants: true,
    descendants_max_depth: 2,
    extend: ['otus']
  }
  const descendants = {
    taxon_names: [],
    collecting_events: [],
    georeferences: []
  }

  TaxonName.all(params)
    .then((response) => {
      descendants.taxon_names = response.body.filter(
        (tn) => tn.id !== otu.taxon_name_id
      )

      commit(MutationNames.SetDescendants, descendants)
      state.loadState.descendantsDistribution = false
    })
    .finally(() => {
      state.loadState.descendants = false
    })
}
