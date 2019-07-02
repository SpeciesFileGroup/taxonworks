import getMatrix from './getMatrix'
import getObservations from './getObservations'
import getObservationColumns from './getObservationColumns'
import getObservationRows from './getObservationRows'
import getObservationMoved from './getObservationMoved'

const GetterNames = {
  GetMatrix: 'getMatrix',
  GetObservations: 'getObservations',
  GetObservationColumns: 'getObservationColumns',
  GetObservationRows: 'getObservationRows',
  GetObservationMoved: 'getObservationMoved'
}

const GetterFunctions = {
  [GetterNames.GetMatrix]: getMatrix,
  [GetterNames.GetObservations]: getObservations,
  [GetterNames.GetObservationColumns]: getObservationColumns,
  [GetterNames.GetObservationRows]: getObservationRows,
  [GetterNames.GetObservationMoved]: getObservationMoved
}

export {
  GetterNames,
  GetterFunctions
}