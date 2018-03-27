import getMatrix from './getMatrix'
import getMatrixRows from './getMatrixRows'
import getMatrixView from './getMatrixView'
import getMatrixMode from './getMatrixMode'

const GetterNames = {
  GetMatrix: 'getMatrix',
  GetMatrixRows: 'getMatrixRows',
  GetMatrixView: 'getMatrixView',
  GetMatrixMode: 'getMatrixMode'
}

const GetterFunctions = {
  [GetterNames.GetMatrix]: getMatrix,
  [GetterNames.GetMatrixRows]: getMatrixRows,
  [GetterNames.GetMatrixView]: getMatrixView,
  [GetterNames.GetMatrixMode]: getMatrixMode,
}

export {
  GetterNames,
  GetterFunctions
}