import setMatrix from './setMatrix'
import setMatrixName from './setMatrixName'
import setMatrixRows from './setMatrixRows'
import setMatrixColumns from './setMatrixColumns'
import addRowItem from './addRowItem'

const MutationNames = {
  SetMatrix: 'setMatrix',
  SetMatrixName: 'setMatrixName',
  SetMatrixColumns: 'setMatrixColumns',
  SetMatrixRows: 'setMatrixRows',
  AddRowItem: 'addRowItem'
}

const MutationFunctions = {
  [MutationNames.SetMatrix]: setMatrix,
  [MutationNames.SetMatrixRows]: setMatrixRows,
  [MutationNames.SetMatrixColumns]: setMatrixColumns,
  [MutationNames.SetMatrixName]: setMatrixName,
  [MutationNames.AddRowItem]: addRowItem,
}

export {
  MutationNames,
  MutationFunctions
}