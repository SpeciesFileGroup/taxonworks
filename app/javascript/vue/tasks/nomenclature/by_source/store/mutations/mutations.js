import setOtuList from './setOtuList.js'
import setSource from './setSource.js'

const MutationNames = {
  SetOtuList: 'setOtuList',
  SetSource: 'setSource'
}

const MutationFunctions = {
  [MutationNames.SetOtuList]: setOtuList,
  [MutationNames.SetSource]: setSource
}

export { 
  MutationFunctions,
  MutationNames
}
