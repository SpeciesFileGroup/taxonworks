import setOtuList from './setOtuList.js'

const MutationNames = {
  SetOtuList: 'setOtuList'
}

const MutationFunctions = {
  [MutationNames.SetOtuList]: setOtuList
}

export { 
  MutationFunctions,
  MutationNames
}
