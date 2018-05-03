import getMatrix from './getMatrix'
import getMatrixRows from './getMatrixRows'
import getMatrixColumns from './getMatrixColumns'
import getMatrixRowsDynamic from './getMatrixRowsDynamic'
import getMatrixColumnsDynamic from './getMatrixColumnsDynamic'
import getMatrixView from './getMatrixView'
import getMatrixMode from './getMatrixMode'

const GetterNames = {
  GetMatrix: 'getMatrix',
  GetMatrixRows: 'getMatrixRows',
  GetMatrixRowsDynamic: 'getMatrixRowsDynamic',
  GetMatrixView: 'getMatrixView',
  GetMatrixMode: 'getMatrixMode',
  GetMatrixColumns: 'getMatrixColumns',
  GetMatrixColumnsDynamic: 'getMatrixColumnsDynamic'
}

const GetterFunctions = {
  [GetterNames.GetMatrix]: getMatrix,
  [GetterNames.GetMatrixRows]: getMatrixRows,
  [GetterNames.GetMatrixRowsDynamic]: getMatrixRowsDynamic,
  [GetterNames.GetMatrixView]: getMatrixView,
  [GetterNames.GetMatrixMode]: getMatrixMode,
  [GetterNames.GetMatrixColumns]: getMatrixColumns,
  [GetterNames.GetMatrixColumnsDynamic]: getMatrixColumnsDynamic
}

export {
  GetterNames,
  GetterFunctions
}