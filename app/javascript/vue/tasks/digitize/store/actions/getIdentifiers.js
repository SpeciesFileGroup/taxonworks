import { Identifier } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import { IDENTIFIER_LOCAL_CATALOG_NUMBER } from 'constants/index.js'

export default ({ commit }, { id, type }) => {
  return new Promise((resolve, reject) => {
    Identifier.where({
      identifier_object_type: type,
      identifier_object_id: id,
      type: IDENTIFIER_LOCAL_CATALOG_NUMBER
    }).then(response => {
      commit(MutationNames.SetIdentifiers, response.body)
      resolve(response.body)
    }, response => {
      reject(response.body)
    })
  })
}