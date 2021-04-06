import setExtract from './setExtract'
import setIdentifiers from './setIdentifiers'
import setSettings from './setSettings'
import setSoftValidation from './setSoftValidation'
import setUserPreferences from './setUserPreferences'
import setProjectPreferences from './setProjectPreferences'
import setOriginRelationship from './setOriginRelationship'

const MutationNames = {
  SetExtract: 'setExtract',
  SetIdentifiers: 'setIdentifiers',
  SetSettings: 'setSettings',
  SetSoftValidation: 'setSoftValidation',
  SetUserPreferences: 'setUserPreferences',
  SetProjectPreferences: 'setProjectPreferences',
  SetOriginRelationship: 'setOriginRelationship'
}

const MutationFunctions = {
  [MutationNames.SetExtract]: setExtract,
  [MutationNames.SetIdentifiers]: setIdentifiers,
  [MutationNames.SetSettings]: setSettings,
  [MutationNames.SetSoftValidation]: setSoftValidation,
  [MutationNames.SetUserPreferences]: setUserPreferences,
  [MutationNames.SetProjectPreferences]: setProjectPreferences,
  [MutationNames.SetOriginRelationship]: setOriginRelationship
}

export {
  MutationNames,
  MutationFunctions
}
