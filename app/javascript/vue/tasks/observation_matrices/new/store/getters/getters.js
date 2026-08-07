import getMatrix from './getMatrix'
import getMatrixRows from './getMatrixRows'
import getMatrixColumns from './getMatrixColumns'
import getMatrixRowsDynamic from './getMatrixRowsDynamic'
import getMatrixColumnsDynamic from './getMatrixColumnsDynamic'
import getMatrixView from './getMatrixView'
import getMatrixMode from './getMatrixMode'
import getRowFixedPagination from './getRowFixedPagination'
import getColumnFixedPagination from './getColumnFixedPagination'
import getSettings from './getSettings'

const GetterNames = {
  GetMatrix: 'getMatrix',
  GetMatrixRows: 'getMatrixRows',
  GetMatrixRowsDynamic: 'getMatrixRowsDynamic',
  GetMatrixView: 'getMatrixView',
  GetMatrixMode: 'getMatrixMode',
  GetMatrixColumns: 'getMatrixColumns',
  GetMatrixColumnsDynamic: 'getMatrixColumnsDynamic',
  GetRowFixedPagination: 'getRowFixedPagination',
  GetColumnFixedPagination: 'getColumnFixedPagination',
  GetSettings: 'getSettings'
}

const GetterFunctions = {
  [GetterNames.GetMatrix]: getMatrix,
  [GetterNames.GetMatrixRows]: getMatrixRows,
  [GetterNames.GetMatrixRowsDynamic]: getMatrixRowsDynamic,
  [GetterNames.GetMatrixView]: getMatrixView,
  [GetterNames.GetMatrixMode]: getMatrixMode,
  [GetterNames.GetMatrixColumns]: getMatrixColumns,
  [GetterNames.GetMatrixColumnsDynamic]: getMatrixColumnsDynamic,
  [GetterNames.GetRowFixedPagination]: getRowFixedPagination,
  [GetterNames.GetColumnFixedPagination]: getColumnFixedPagination,
  [GetterNames.GetSettings]: getSettings
}

export {
  GetterNames,
  GetterFunctions
}