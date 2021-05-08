import { CollectionObject } from 'routes/endpoints'
import { MutationNames } from '../../store/mutations/mutations'
import SetParam from 'helpers/setParam'

export default ({ commit, state }, co) =>
  new Promise((resolve, reject) => {
    const collection_object = co
    collection_object.collecting_event_id = state.collection_event.id

    if (collection_object.id) {
      CollectionObject.update(co.id, { collection_object }).then(response => {
        return resolve(response.body)
      }, (response) => {
        return reject(response)
      })
    } else {
      CollectionObject.create({ collection_object }).then(response => {
        commit(MutationNames.SetSubsequentialUses, (state.subsequentialUses + 1))
        SetParam('/tasks/accessions/comprehensive', 'collection_object_id', response.body.id)
        return resolve(response.body)
      }, (response) => {
        return reject(response)
      })
    }
  })
