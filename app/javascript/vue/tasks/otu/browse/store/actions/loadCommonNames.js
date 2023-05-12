import { MutationNames } from '../mutations/mutations'
import { CommonName } from 'routes/endpoints'

export default ({ commit, state }, id) =>
  CommonName.all({ otu_id: id }).then((response) => {
    commit(
      MutationNames.SetCommonNames,
      state.commonNames.concat(response.body)
    )
  })
