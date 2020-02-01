import resetStore from './resetStore'
import setCollectionObject from './setCollectionObject'
import setSledImage from './setSledImage'
import setIdentifier from './setIdentifier'
import setImage from './setImage'
import setNavigation from './setNavigation'

const MutationNames = {
  SetCollectionObject: 'setCollectionObject',
  SetIdentifier: 'setIdentifier',
  SetSledImage: 'setSledImage',
  SetImage: 'setImage',
  SetNavigation: 'setNavigation',
  ResetStore: 'resetStore'
}

const MutationFunctions = {
  [MutationNames.SetCollectionObject]: setCollectionObject,
  [MutationNames.SetIdentifier]: setIdentifier,
  [MutationNames.SetSledImage]: setSledImage,
  [MutationNames.SetImage]: setImage,
  [MutationNames.SetNavigation]: setNavigation,
  [MutationNames.ResetStore]: resetStore,
}

export {
  MutationNames,
  MutationFunctions
}
