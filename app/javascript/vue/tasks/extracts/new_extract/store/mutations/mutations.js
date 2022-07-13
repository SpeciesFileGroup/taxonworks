import addIdentifier from './addIdentifier'
import addProtocol from './addProtocol'
import addOriginToList from './addOriginToList'
import setExtract from './setExtract'
import setIdentifiers from './setIdentifiers'
import setRecents from './setRecent'
import setSettings from './setSettings'
import setSoftValidation from './setSoftValidation'
import setUserPreferences from './setUserPreferences'
import setProjectPreferences from './setProjectPreferences'
import setOriginRelationship from './setOriginRelationship'
import setOriginRelationships from './setOriginRelationships'
import setRepository from './setRepository'
import setProtocols from './setProtocols'
import setState from './setState'
import setLastChange from './setLastChange'
import setLastSave from './setLastSave'
import removeProtocol from './removeProtocol'
import removeIdentifierByIndex from './removeIdentifierByIndex'
import setRoles from './setRoles'

const MutationNames = {
  AddIdentifier: 'addIdentifier',
  AddProtocol: 'addProtocol',
  AddOriginToList: 'addOriginToList',
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
  [MutationNames.AddIdentifier]: addIdentifier,
  [MutationNames.AddProtocol]: addProtocol,
  [MutationNames.AddOriginToList]: addOriginToList,
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

export {
  MutationNames,
  MutationFunctions
}
