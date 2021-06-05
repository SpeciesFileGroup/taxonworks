import { TaxonNameClassification } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit }) {
  return new Promise(function (resolve, reject) {
    TaxonNameClassification.types().then(response => {
      commit(MutationNames.SetStatusList, response.body)
      return resolve()
    })
  })
}
