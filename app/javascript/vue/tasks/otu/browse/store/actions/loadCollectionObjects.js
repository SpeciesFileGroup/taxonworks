import { CollectionObject } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }, otuId) =>
  new Promise((resolve, reject) => {
    CollectionObject.where({ otu_ids: otuId, current_determinations: true }).then(response => {
      state.loadState.collectionObjects = false
      commit(MutationNames.SetCollectionObjects, state.collectionObjects.concat(response.body))
      resolve(response)
    }, (error) => {
      reject(error)
    })
  })
