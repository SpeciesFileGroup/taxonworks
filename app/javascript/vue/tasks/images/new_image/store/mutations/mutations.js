import setLicense from './setLicense'
import setImagesCreated from './setImagesCreated'

const MutationNames = {
  SetLicense: 'setLicense',
  SetImagesCreated: 'setImagesCreated'
}

const MutationFunctions = {
  [MutationNames.SetLicense]: setLicense,
  [MutationNames.SetImagesCreated]: setImagesCreated
}

export {
  MutationNames,
  MutationFunctions
}
