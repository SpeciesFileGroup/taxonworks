import { TaxonDetermination } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import { ActionNames } from './actions'

export default ({ commit, dispatch }, id) =>
  new Promise((resolve, reject) => {
    TaxonDetermination.where({ biological_collection_object_id: [id] }).then(
      async (response) => {
        commit(MutationNames.SetTaxonDeterminations, response.body)

        if (!response.body.length) {
          dispatch(ActionNames.CreateDeterminationFromParams)
        }

        resolve(response.body)
      },
      (error) => {
        reject(error)
      }
    )
  })
