import resetStore from './resetStore'
import setCollectionObject from './setCollectionObject'
import setSledImage from './setSledImage'
import setIdentifier from './setIdentifier'
import setImage from './setImage'
import setNavigation from './setNavigation'
import setDepiction from './setDepiction'

const MutationNames = {
  SetCollectionObject: 'setCollectionObject',
  SetIdentifier: 'setIdentifier',
  SetSledImage: 'setSledImage',
  SetImage: 'setImage',
  SetNavigation: 'setNavigation',
  ResetStore: 'resetStore',
  SetDepiction: 'setDepiction'
}

const MutationFunctions = {
  [MutationNames.SetCollectionObject]: setCollectionObject,
  [MutationNames.SetIdentifier]: setIdentifier,
  [MutationNames.SetSledImage]: setSledImage,
  [MutationNames.SetImage]: setImage,
  [MutationNames.SetNavigation]: setNavigation,
  [MutationNames.ResetStore]: resetStore,
  [MutationNames.SetDepiction]: setDepiction
}

export {
  MutationNames,
  MutationFunctions
}
