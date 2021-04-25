import { TaxonNameRelationships } from 'routes/endpoints/TaxonNameRelationships'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }) {
  return new Promise(function (resolve, reject) {
    TaxonNameRelationships.types().then(response => {
      commit(MutationNames.SetRelationshipList, response.body)
      return resolve()
    })
  })
}
