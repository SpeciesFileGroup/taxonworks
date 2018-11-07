import { MutationNames } from '../mutations/mutations'
import newCollectionObject from '../../const/collectionObject'

export default function ({ commit, state }) {
  let newCO = newCollectionObject()
  let locked = state.settings.locked.collection_object
  let keys = Object.keys(locked)
  keys.forEach(key => {
    newCO[key] = locked[key] ? state.collection_object[key] : undefined
  })
  commit(MutationNames.SetCollectionObject, newCO)
  commit(MutationNames.NewTypeMaterial)
}