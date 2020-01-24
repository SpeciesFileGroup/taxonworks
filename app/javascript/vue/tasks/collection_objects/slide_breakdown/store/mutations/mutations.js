import resetStore from './resetStore'
import setCollectionObject from './setCollectionObject'
import setSledImage from './setSledImage'
import setIdentifier from './setIdentifier'
import setImage from './setImage'

const MutationNames = {
  SetCollectionObject: 'setCollectionObject',
  SetIdentifier: 'setIdentifier',
  SetSledImage: 'setSledImage',
  SetImage: 'setImage',
  ResetStore: 'resetStore'
}

const MutationFunctions = {
  [MutationNames.SetCollectionObject]: setCollectionObject,
  [MutationNames.SetIdentifier]: setIdentifier,
  [MutationNames.SetSledImage]: setSledImage,
  [MutationNames.SetImage]: setImage,
  [MutationNames.ResetStore]: resetStore,
}

export {
  MutationNames,
  MutationFunctions
}
