import { MutationNames } from '../mutations/mutations'
import { TaxonName } from 'routes/endpoints'

export default ({ commit }, id) =>
  new Promise((resolve, reject) => {
    commit(MutationNames.SetLoading, true)
    TaxonName.find(id).then(response => {
      commit(MutationNames.SetProtonymId, id)
      commit(MutationNames.SetTaxon, response.body)
      return resolve(response.body)
    }, (error) => {
      commit(MutationNames.SetLoading, false)
      return reject(error)
    })
  })
