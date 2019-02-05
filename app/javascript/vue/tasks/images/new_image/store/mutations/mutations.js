import setLicense from './setLicense'
import setImagesCreated from './setImagesCreated'
import setAuthors from './setAuthors'
import setEditors from './setEditors'
import setOwners from './setOwners'
import setCopyrightHolders from './setCopyrightHolder'

const MutationNames = {
  SetLicense: 'setLicense',
  SetImagesCreated: 'setImagesCreated',
  SetAuthors: 'setAuthors',
  SetEditors: 'SetEditors',
  SetOwners: 'setOwners',
  SetCopyrightHolder: 'setCopyrightHolder'
}

const MutationFunctions = {
  [MutationNames.SetLicense]: setLicense,
  [MutationNames.SetImagesCreated]: setImagesCreated,
  [MutationNames.SetAuthors]: setAuthors,
  [MutationNames.SetEditors]: setEditors,
  [MutationNames.SetOwners]: setOwners,
  [MutationNames.SetCopyrightHolder]: setCopyrightHolders
}

export {
  MutationNames,
  MutationFunctions
}
