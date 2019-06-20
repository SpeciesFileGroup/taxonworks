import getMatrix from './getMatrix'
import getObservations from './getObservations'
import getObservationColumns from './getObservationColumns'
import getObservationRows from './getObservationRows'

const GetterNames = {
  GetMatrix: 'getMatrix',
  GetObservations: 'getObservations',
  GetObservationColumns: 'getObservationColumns',
  GetObservationRows: 'getObservationRows',
}

const GetterFunctions = {
  [GetterNames.GetMatrix]: getMatrix,
  [GetterNames.GetObservations]: getObservations,
  [GetterNames.GetObservationColumns]: getObservationColumns,
  [GetterNames.GetObservationRows]: getObservationRows,
}

export {
  GetterNames,
  GetterFunctions
}