import { Identifier } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }, id) => {
  return new Promise((resolve, reject) => {
    Identifier.where({
      identifier_object_type: 'CollectionObject',
      identifier_object_id: id,
      type: 'Identifier::Local::CatalogNumber'
    }).then(response => {
      commit(MutationNames.SetIdentifiers, response.body)
      resolve(response.body)
    })
  })
}