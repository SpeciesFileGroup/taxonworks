import { TaxonNameClassifications } from 'routes/endpoints/TaxonNameClassifications.js'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit }) {
  return new Promise(function (resolve, reject) {
    TaxonNameClassifications.types().then(response => {
      commit(MutationNames.SetStatusList, response.body)
      return resolve()
    })
  })
}
