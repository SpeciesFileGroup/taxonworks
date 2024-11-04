import addConfidence from './addConfidence'
import addIdentifier from './addIdentifier'
import addOriginToList from './addOriginToList'
import addProtocol from './addProtocol'
import removeIdentifierByIndex from './removeIdentifierByIndex'
import removeProtocol from './removeProtocol'
import setConfidences from './setConfidences'
import setExtract from './setExtract'
import setIdentifiers from './setIdentifiers'
import setLastChange from './setLastChange'
import setLastSave from './setLastSave'
import setOriginRelationship from './setOriginRelationship'
import setOriginRelationships from './setOriginRelationships'
import setProjectPreferences from './setProjectPreferences'
import setProtocols from './setProtocols'
import setRecents from './setRecent'
import setRepository from './setRepository'
import setRoles from './setRoles'
import setSettings from './setSettings'
import setSoftValidation from './setSoftValidation'
import setState from './setState'
import setUserPreferences from './setUserPreferences'

const MutationNames = {
  AddConfidence: 'addConfidence',
  AddIdentifier: 'addIdentifier',
  AddProtocol: 'addProtocol',
  AddOriginToList: 'addOriginToList',
  SetConfidences: 'setConfidences',
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
  SetOriginRelationships: 'setOriginRelationships',
  RemoveIdentifierByIndex: 'removeIdentifierByIndex',
  RemoveProtocol: 'removeProtocol',
  SetRoles: 'setRoles'
}

const MutationFunctions = {
  [MutationNames.AddConfidence]: addConfidence,
  [MutationNames.AddIdentifier]: addIdentifier,
  [MutationNames.AddProtocol]: addProtocol,
  [MutationNames.AddOriginToList]: addOriginToList,
  [MutationNames.SetConfidences]: setConfidences,
  [MutationNames.SetExtract]: setExtract,
  [MutationNames.SetIdentifiers]: setIdentifiers,
  [MutationNames.SetRecents]: setRecents,
  [MutationNames.SetSettings]: setSettings,
  [MutationNames.SetSoftValidation]: setSoftValidation,
  [MutationNames.SetUserPreferences]: setUserPreferences,
  [MutationNames.SetProjectPreferences]: setProjectPreferences,
  [MutationNames.SetOriginRelationship]: setOriginRelationship,
  [MutationNames.SetOriginRelationships]: setOriginRelationships,
  [MutationNames.SetRepository]: setRepository,
  [MutationNames.SetProtocols]: setProtocols,
  [MutationNames.SetState]: setState,
  [MutationNames.SetLastChange]: setLastChange,
  [MutationNames.SetLastSave]: setLastSave,
  [MutationNames.RemoveIdentifierByIndex]: removeIdentifierByIndex,
  [MutationNames.RemoveProtocol]: removeProtocol,
  [MutationNames.SetRoles]: setRoles
}

export { MutationNames, MutationFunctions }
