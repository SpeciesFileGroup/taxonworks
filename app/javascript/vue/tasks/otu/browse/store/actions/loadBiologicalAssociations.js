import { MutationNames } from '../mutations/mutations'
import { BiologicalAssociation } from 'routes/endpoints'

const extend = [
  'citations',
  'object',
  'subject',
  'biological_relationship',
  'source'
]

export default ({ state, commit }, globalId) =>
  new Promise((resolve, reject) => {
    BiologicalAssociation.where({ any_global_id: globalId, extend }).then(response => {
      commit(MutationNames.SetBiologicalAssociations, state.biologicalAssociations.concat(response.body))
      resolve(response)
    }, error => {
      reject(error)
    })
  })
