import { MutationNames } from '../mutations/mutations'
import makeCollectionObject from '@/factory/CollectionObject'

export default ({ commit, state }) => {
  const lockSettings = state.settings.locked
  const newCO = makeCollectionObject()
  const lockedCO = lockSettings.collection_object
  const keys = Object.keys(lockedCO)

  keys.forEach((key) => {
    newCO[key] = lockedCO[key] ? state.collection_object[key] : undefined
  })

  state.coCitations = lockSettings.coCitations
    ? state.coCitations.map((citation) => ({ ...citation, id: undefined }))
    : []

  history.replaceState(null, null, '/tasks/accessions/comprehensive')
  commit(MutationNames.SetCollectionObject, newCO)
  commit(MutationNames.NewTypeMaterial)
}
