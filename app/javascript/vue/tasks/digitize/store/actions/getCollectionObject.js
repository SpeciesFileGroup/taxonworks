import { CollectionObject } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import SetParam from 'helpers/setParam'

export default ({ commit }, id) =>
  new Promise((resolve, reject) => {
    SetParam('/tasks/accessions/comprehensive', 'collection_object_id', id)
    CollectionObject.find(id).then(response => {
      commit(MutationNames.SetCollectionObject, response.body)
      resolve(response.body)
    })
  })
