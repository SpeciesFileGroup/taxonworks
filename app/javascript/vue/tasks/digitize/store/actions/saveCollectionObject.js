import { CreateCollectionObject, UpdateCollectionObject } from '../../request/resources'
import { MutationNames } from '../../store/mutations/mutations'
import SetParam from 'helpers/setParam'

export default function ({ commit, state }, co) {
  return new Promise((resolve, reject) => {
    let collection_object = co
    collection_object.collecting_event_id = state.collection_event.id
    if(collection_object.id) {
      UpdateCollectionObject(collection_object).then(response => {
        return resolve(response)
      }, (response) => {
        TW.workbench.alert.create(JSON.stringify(Object.keys(response.body).map(key => { return response.body[key] }).join('<br>')), 'error')
        return reject(response)
      })
    }
    else {
      CreateCollectionObject(collection_object).then(response => {
        commit(MutationNames.SetSubsequentialUses, (state.subsequentialUses + 1))
        SetParam('/tasks/accessions/comprehensive', 'collection_object_id', response.id)
        return resolve(response)
      }, (response) => {
        TW.workbench.alert.create(JSON.stringify(Object.keys(response.body).map(key => { return response.body[key] }).join('<br>')), 'error')
        return reject(response)
      })
    }
  })
}