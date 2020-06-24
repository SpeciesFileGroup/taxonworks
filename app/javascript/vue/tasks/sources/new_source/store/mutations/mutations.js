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

const MutationNames = {
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
  SetSerialId: 'setSerialId'
}

const MutationFunctions = {
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
  [MutationNames.SetSerialId]: setSerialId
}

export {
  MutationNames,
  MutationFunctions
}
