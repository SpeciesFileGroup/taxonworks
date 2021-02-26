import setExtract from './setExtract'
import setSettings from './setSettings'
import setSoftValidation from './setSoftValidation'

const MutationNames = {
  SetExtract: 'setExtract',
  SetSettings: 'setSettings',
  SetSoftValidation: 'setSoftValidation'
}

const MutationFunctions = {
  [MutationNames.SetExtract]: setExtract,
  [MutationNames.SetSettings]: setSettings,
  [MutationNames.SetSoftValidation]: setSoftValidation
}

export {
  MutationNames,
  MutationFunctions
}
