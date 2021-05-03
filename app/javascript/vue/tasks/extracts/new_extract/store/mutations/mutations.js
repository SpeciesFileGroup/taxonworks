import addIdentifier from './addIdentifier'
import addProtocol from './addProtocol'
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
import setLastChange from './setLastChange'
import setLastSave from './setLastSave'
import removeProtocol from './removeProtocol'
import removeIdentifierByIndex from './removeIdentifierByIndex'

const MutationNames = {
  AddIdentifier: 'addIdentifier',
  AddProtocol: 'addProtocol',
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
  SetState: 'setState',
  SetLastChange: 'setLastChange',
  SetLastSave: 'setLastSave',
  RemoveIdentifierByIndex: 'removeIdentifierByIndex',
  RemoveProtocol: 'removeProtocol'
}

const MutationFunctions = {
  [MutationNames.AddIdentifier]: addIdentifier,
  [MutationNames.AddProtocol]: addProtocol,
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
  [MutationNames.SetState]: setState,
  [MutationNames.SetLastChange]: setLastChange,
  [MutationNames.SetLastSave]: setLastSave,
  [MutationNames.RemoveIdentifierByIndex]: removeIdentifierByIndex,
  [MutationNames.RemoveProtocol]: removeProtocol
}

export {
  MutationNames,
  MutationFunctions
}
