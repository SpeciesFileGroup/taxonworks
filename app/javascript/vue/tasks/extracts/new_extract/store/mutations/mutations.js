import setExtract from './setExtract'
import setIdentifiers from './setIdentifiers'
import setSettings from './setSettings'
import setSoftValidation from './setSoftValidation'
import setUserPreferences from './setUserPreferences'
import setProjectPreferences from './setProjectPreferences'
import setOriginRelationship from './setOriginRelationship'
import setRepository from './setRepository'

const MutationNames = {
  SetExtract: 'setExtract',
  SetIdentifiers: 'setIdentifiers',
  SetSettings: 'setSettings',
  SetSoftValidation: 'setSoftValidation',
  SetUserPreferences: 'setUserPreferences',
  SetProjectPreferences: 'setProjectPreferences',
  SetOriginRelationship: 'setOriginRelationship',
  SetRepository: 'setRepository'
}

const MutationFunctions = {
  [MutationNames.SetExtract]: setExtract,
  [MutationNames.SetIdentifiers]: setIdentifiers,
  [MutationNames.SetSettings]: setSettings,
  [MutationNames.SetSoftValidation]: setSoftValidation,
  [MutationNames.SetUserPreferences]: setUserPreferences,
  [MutationNames.SetProjectPreferences]: setProjectPreferences,
  [MutationNames.SetOriginRelationship]: setOriginRelationship,
  [MutationNames.SetRepository]: setRepository
}

export {
  MutationNames,
  MutationFunctions
}
