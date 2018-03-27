import setMatrix from './setMatrix'
import setMatrixName from './setMatrixName'
import setMatrixRows from './setMatrixRows'
import setMatrixColumns from './setMatrixColumns'
import addRowItem from './addRowItem'
import setMatrixView from './setMatrixView'
import setMatrixMode from './setMatrixMode'

const MutationNames = {
  SetMatrix: 'setMatrix',
  SetMatrixName: 'setMatrixName',
  SetMatrixColumns: 'setMatrixColumns',
  SetMatrixRows: 'setMatrixRows',
  SetMatrixView: 'setMatrixView',
  SetMatrixMode: 'setMatrixMode',
  AddRowItem: 'addRowItem'
}

const MutationFunctions = {
  [MutationNames.SetMatrix]: setMatrix,
  [MutationNames.SetMatrixRows]: setMatrixRows,
  [MutationNames.SetMatrixColumns]: setMatrixColumns,
  [MutationNames.SetMatrixName]: setMatrixName,
  [MutationNames.SetMatrixView]: setMatrixView,
  [MutationNames.SetMatrixMode]: setMatrixMode,
  [MutationNames.AddRowItem]: addRowItem,
}

export {
  MutationNames,
  MutationFunctions
}