import setOtuList from './setOtuList.js'
import setSource from './setSource.js'
import removeCitation from './removeCitation.js'

const MutationNames = {
  SetOtuList: 'setOtuList',
  SetSource: 'setSource',
  RemoveCitation: 'removeCitation'
}

const MutationFunctions = {
  [MutationNames.SetOtuList]: setOtuList,
  [MutationNames.SetSource]: setSource,
  [MutationNames.RemoveCitation]: removeCitation
}

export { 
  MutationFunctions,
  MutationNames
}
