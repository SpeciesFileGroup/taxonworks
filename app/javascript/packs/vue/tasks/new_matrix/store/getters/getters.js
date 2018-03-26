import getMatrix from './getMatrix'
import getMatrixRows from './getMatrixRows'

const GetterNames = {
  GetMatrix: 'getMatrix',
  GetMatrixRows: 'getMatrixRows',
}

const GetterFunctions = {
  [GetterNames.GetMatrix]: getMatrix,
  [GetterNames.GetMatrixRows]: getMatrixRows,
}

export {
  GetterNames,
  GetterFunctions
}