import setMatrix from './setMatrix'
import setMatrixName from './setMatrixName'
import addRowItem from './addRowItem'

const MutationNames = {
  SetMatrix: 'setMatrix',
  SetMatrixName: 'setMatrixName',
  AddRowItem: 'addRowItem'
}

const MutationFunctions = {
  [MutationNames.SetMatrix]: setMatrix,
  [MutationNames.SetMatrixName]: setMatrixName,
  [MutationNames.AddRowItem]: addRowItem,
}

export {
  MutationNames,
  MutationFunctions
}