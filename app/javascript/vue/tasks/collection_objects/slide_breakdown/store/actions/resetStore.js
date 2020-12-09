import { MutationNames } from '../mutations/mutations'
import { makeInitialState } from '../store'

export default ({ commit, state }) => {
  const collectionObject = state.collection_object
  const identifier = state.identifier
  const store = makeInitialState()
  const keys = Object.keys(collectionObject)
  keys.forEach(item => {
    collectionObject[item] = state.settings.lock[item] ? collectionObject[item] : store.collection_object[item]
  })
  if(state.settings.lock.identifier) {
    store.identifier = identifier
  }
  store.collection_object = collectionObject
  store.settings = state.settings

  commit(MutationNames.SetStore, store)
}
