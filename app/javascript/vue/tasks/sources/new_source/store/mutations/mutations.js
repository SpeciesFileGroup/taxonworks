import setType from './setType'
import setVerbatim from './setVerbatim'
import setBibtexType from './setBibtexType'
import setSource from './setSource'
import setPreferences from './setPreferences'
import setSettings from './setSettings'
import setRoles from './setRoles'

const MutationNames = {
  SetType: 'setType',
  SetVerbatim: 'setVerbatim',
  SetBibtexType: 'setBibtexType',
  SetSource: 'setSource',
  SetPreferences: 'setPreferences',
  SetSettings: 'setSettings',
  SetRoles: 'setRoles'
}

const MutationFunctions = {
  [MutationNames.SetType]: setType,
  [MutationNames.SetVerbatim]: setVerbatim,
  [MutationNames.SetBibtexType]: setBibtexType,
  [MutationNames.SetSource]: setSource,
  [MutationNames.SetPreferences]: setPreferences,
  [MutationNames.SetSettings]: setSettings,
  [MutationNames.SetRoles]: setRoles
}

export {
  MutationNames,
  MutationFunctions
}
