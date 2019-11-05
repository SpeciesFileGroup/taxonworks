import setType from './setType'
import setVerbatim from './setVerbatim'
import setBibtexType from './setBibtexType'
import setSource from './setSource'

const MutationNames = {
  SetType: 'setType',
  SetVerbatim: 'setVerbatim',
  SetBibtexType: 'setBibtexType',
  SetSource: 'setSource'
}

const MutationFunctions = {
  [MutationNames.SetType]: setType,
  [MutationNames.SetVerbatim]: setVerbatim,
  [MutationNames.SetBibtexType]: setBibtexType,
  [MutationNames.SetSource]: setSource
}

export {
  MutationNames,
  MutationFunctions
}
