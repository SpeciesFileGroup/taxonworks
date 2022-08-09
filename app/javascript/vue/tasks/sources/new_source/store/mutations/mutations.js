import addDocumentation from './addDocumentation'
import setDocumentation from './setDocumentation'
import setType from './setType'
import setVerbatim from './setVerbatim'
import setBibtexType from './setBibtexType'
import setSource from './setSource'
import setPreferences from './setPreferences'
import setSettings from './setSettings'
import setRoles from './setRoles'
import setSoftValidation from './setSoftValidation'
import addRole from './addRole'
import setLastSave from './setLastSave'
import setSerialId from './setSerialId'
import setLanguageId from './setLanguageId'

const MutationNames = {
  AddDocumentation: 'addDocumentation',
  SetDocumentation: 'setDocumentation',
  SetType: 'setType',
  SetVerbatim: 'setVerbatim',
  SetBibtexType: 'setBibtexType',
  SetSource: 'setSource',
  SetPreferences: 'setPreferences',
  SetSettings: 'setSettings',
  SetRoles: 'setRoles',
  SetSoftValidation: 'setSoftValidation',
  AddRole: 'addRole',
  SetLastSave: 'setLastSave',
  SetSerialId: 'setSerialId',
  SetLanguageId: 'setLanguageId'
}

const MutationFunctions = {
  [MutationNames.AddDocumentation]: addDocumentation,
  [MutationNames.SetDocumentation]: setDocumentation,
  [MutationNames.SetType]: setType,
  [MutationNames.SetVerbatim]: setVerbatim,
  [MutationNames.SetBibtexType]: setBibtexType,
  [MutationNames.SetSource]: setSource,
  [MutationNames.SetPreferences]: setPreferences,
  [MutationNames.SetSettings]: setSettings,
  [MutationNames.SetRoles]: setRoles,
  [MutationNames.SetSoftValidation]: setSoftValidation,
  [MutationNames.AddRole]: addRole,
  [MutationNames.SetLastSave]: setLastSave,
  [MutationNames.SetSerialId]: setSerialId,
  [MutationNames.SetLanguageId]: setLanguageId
}

export {
  MutationNames,
  MutationFunctions
}
