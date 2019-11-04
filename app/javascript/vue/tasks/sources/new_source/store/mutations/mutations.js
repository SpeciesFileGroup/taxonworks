import setType from './setType'
import setVerbatim from './setVerbatim'
import setBibtexType from './setBibtexType'

const MutationNames = {
  SetType: 'setType',
  SetVerbatim: 'setVerbatim',
  SetBibtexType: 'setBibtexType'
}

const MutationFunctions = {
  [MutationNames.SetType]: setType,
  [MutationNames.SetVerbatim]: setVerbatim,
  [MutationNames.SetBibtexType]: setBibtexType
}

export {
  MutationNames,
  MutationFunctions
}
