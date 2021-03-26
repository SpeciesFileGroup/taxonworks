import { GetCollectionObject } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'
import SetParam from 'helpers/setParam'

export default function ({ commit, state }, id) {
  return new Promise((resolve, reject) => {
    SetParam('/tasks/accessions/comprehensive', 'collection_object_id', id)
    GetCollectionObject(id).then(response => {
      commit(MutationNames.SetCollectionObject, response.body)
      resolve(response.body)
    })
  })
}
