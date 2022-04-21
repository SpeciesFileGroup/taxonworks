import { TaxonDetermination, Otu } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import { ActionNames } from './actions'

export default ({ commit, dispatch }, id) => new Promise((resolve, reject) => {
  TaxonDetermination.where({ biological_collection_object_ids: [id] })
    .then(async response => {
      if (response.body.length) {
        commit(MutationNames.SetTaxonDeterminations, response.body)
      } else {
        dispatch(ActionNames.CreateDeterminationFromParams)
      }

      resolve(response.body)
    }, error => {
      reject(error)
    })
})
