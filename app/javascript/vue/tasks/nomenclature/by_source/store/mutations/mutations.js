import setCitationList from './setCitationList.js'
import setOtuList from './setOtuList.js'
import setSource from './setSource.js'
import removeCitation from './removeCitation.js'

const MutationNames = {
  SetCitationList: 'setCitationList',
  SetOtuList: 'setOtuList',
  SetSource: 'setSource',
  RemoveCitation: 'removeCitation'
}

const MutationFunctions = {
  [MutationNames.SetCitationList]: setCitationList,
  [MutationNames.SetOtuList]: setOtuList,
  [MutationNames.SetSource]: setSource,
  [MutationNames.RemoveCitation]: removeCitation
}

export { 
  MutationFunctions,
  MutationNames
}
