import { TaxonNameRelationship } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }) {
  return new Promise(function (resolve, reject) {
    TaxonNameRelationship.types().then(response => {
      commit(MutationNames.SetRelationshipList, response.body)
      return resolve()
    })
  })
}
