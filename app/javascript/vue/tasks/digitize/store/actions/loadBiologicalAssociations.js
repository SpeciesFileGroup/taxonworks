import { BiologicalAssociation } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ commit, state: { collection_object } }) =>
  new Promise((resolve, reject) => {
    BiologicalAssociation.where({ subject_global_id: collection_object.global_id, extend: ['origin_citation'] }).then(({ body })=> {
      commit(MutationNames.SetBiologicalAssociations, body)
      resolve(body)
    }).catch(error => {
      reject(error)
    })
  })
