import { TaxonDetermination } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }, id) =>
  new Promise((resolve, reject) => {
    TaxonDetermination.where({ biological_collection_object_ids: [id] })
      .then(response => {
        commit(MutationNames.SetTaxonDeterminations, response.body)
        resolve(response.body)
      }, error => {
        reject(error)
      })
  })
