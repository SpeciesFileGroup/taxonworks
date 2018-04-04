import getMatrix from './getMatrix'
import getMatrixRows from './getMatrixRows'
import getMatrixColumns from './getMatrixColumns'
import getMatrixView from './getMatrixView'
import getMatrixMode from './getMatrixMode'

const GetterNames = {
  GetMatrix: 'getMatrix',
  GetMatrixRows: 'getMatrixRows',
  GetMatrixView: 'getMatrixView',
  GetMatrixMode: 'getMatrixMode',
  GetMatrixColumns: 'getMatrixColumns'
}

const GetterFunctions = {
  [GetterNames.GetMatrix]: getMatrix,
  [GetterNames.GetMatrixRows]: getMatrixRows,
  [GetterNames.GetMatrixView]: getMatrixView,
  [GetterNames.GetMatrixMode]: getMatrixMode,
  [GetterNames.GetMatrixColumns]: getMatrixColumns
}

export {
  GetterNames,
  GetterFunctions
}