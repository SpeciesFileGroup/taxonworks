import setType from './setType'
import setVerbatim from './setVerbatim'
import setBibtexType from './setBibtexType'
import setSource from './setSource'
import setPreferences from './setPreferences'

const MutationNames = {
  SetType: 'setType',
  SetVerbatim: 'setVerbatim',
  SetBibtexType: 'setBibtexType',
  SetSource: 'setSource',
  SetPreferences: 'setPreferences'
}

const MutationFunctions = {
  [MutationNames.SetType]: setType,
  [MutationNames.SetVerbatim]: setVerbatim,
  [MutationNames.SetBibtexType]: setBibtexType,
  [MutationNames.SetSource]: setSource,
  [MutationNames.SetPreferences]: setPreferences
}

export {
  MutationNames,
  MutationFunctions
}
