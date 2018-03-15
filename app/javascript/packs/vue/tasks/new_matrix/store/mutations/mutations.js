import setMatrix from './setMatrix'
import setMatrixName from './setMatrixName'

const MutationNames = {
  SetMatrix: 'setMatrix',
  SetMatrixName: 'setMatrixName',
}

const MutationFunctions = {
  [MutationNames.SetMatrix]: setMatrix,
  [MutationNames.SetMatrixName]: setMatrixName,
}

export {
  MutationNames,
  MutationFunctions
}