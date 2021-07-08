import { MutationNames } from '../mutations/mutations'
import newCollectionObject from '../../const/collectionObject'

export default ({ commit, state }) => {
  const lockSettings = state.settings.locked
  const newCO = newCollectionObject()
  const lockedCO = lockSettings.collection_object
  const keys = Object.keys(lockedCO)

  keys.forEach(key => {
    newCO[key] = lockedCO[key] ? state.collection_object[key] : undefined
  })

  state.coCitations = lockSettings.coCitations
    ? state.coCitations.map(citation => ({ ...citation, id: undefined }))
    : []

  history.pushState(null, null, '/tasks/accessions/comprehensive')
  commit(MutationNames.SetCollectionObject, newCO)
  commit(MutationNames.NewTypeMaterial)
}