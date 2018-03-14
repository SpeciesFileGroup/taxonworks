import setMatrix from './setMatrix'

const MutationNames = {
  SetMatrix: 'setMatrix',
}

const MutationFunctions = {
  [MutationNames.SetMatrix]: setMatrix,
}

export {
  MutationNames,
  MutationFunctions
}