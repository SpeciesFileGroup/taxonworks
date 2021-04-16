import addIdentifier from './addIdentifier'
import setExtract from './setExtract'
import setIdentifiers from './setIdentifiers'
import setRecents from './setRecent'
import setSettings from './setSettings'
import setSoftValidation from './setSoftValidation'
import setUserPreferences from './setUserPreferences'
import setProjectPreferences from './setProjectPreferences'
import setOriginRelationship from './setOriginRelationship'
import setRepository from './setRepository'
import setProtocols from './setProtocols'
import setState from './setState'

const MutationNames = {
  AddIdentifier: 'addIdentifier',
  SetExtract: 'setExtract',
  SetIdentifiers: 'setIdentifiers',
  SetRecents: 'setRecent',
  SetSettings: 'setSettings',
  SetSoftValidation: 'setSoftValidation',
  SetUserPreferences: 'setUserPreferences',
  SetProjectPreferences: 'setProjectPreferences',
  SetOriginRelationship: 'setOriginRelationship',
  SetRepository: 'setRepository',
  SetProtocols: 'setProtocols',
  SetState: 'setState'
}

const MutationFunctions = {
  [MutationNames.AddIdentifier]: addIdentifier,
  [MutationNames.SetExtract]: setExtract,
  [MutationNames.SetIdentifiers]: setIdentifiers,
  [MutationNames.SetRecents]: setRecents,
  [MutationNames.SetSettings]: setSettings,
  [MutationNames.SetSoftValidation]: setSoftValidation,
  [MutationNames.SetUserPreferences]: setUserPreferences,
  [MutationNames.SetProjectPreferences]: setProjectPreferences,
  [MutationNames.SetOriginRelationship]: setOriginRelationship,
  [MutationNames.SetRepository]: setRepository,
  [MutationNames.SetProtocols]: setProtocols,
  [MutationNames.SetState]: setState
}

export {
  MutationNames,
  MutationFunctions
}
