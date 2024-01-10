import { CollectionObject } from '@/routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import SetParam from '@/helpers/setParam'

export default ({ commit }, id) => {
  SetParam('/tasks/accessions/comprehensive', 'collection_object_id', id)

  const request = CollectionObject.find(id)

  request.then(({ body }) => {
    commit(MutationNames.SetCollectionObject, body)
  })

  return request
}
