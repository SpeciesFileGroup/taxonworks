import { TaxonDetermination } from '@/routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import { ActionNames } from './actions'
import { sortArray } from '@/helpers'

export default ({ commit, dispatch }, id) =>
  new Promise((resolve, reject) => {
    TaxonDetermination.where({ collection_object_id: [id] }).then(
      async (response) => {
        commit(
          MutationNames.SetTaxonDeterminations,
          sortArray(response.body, 'position')
        )

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
