import doesRowObjectNeedCountdown from './doesRowObjectNeedCountdown.js'
import getObservationMatrix from './getObservationMatrix.js'
import getObservations from './getObservations.js'
import getRowObjects from './getRowObjects.js'
import isRowObjectSaving from './isRowObjectSaving.js'
import isRowObjectUnsaved from './isRowObjectUnsaved.js'

const GetterNames = {
  DoesRowObjectNeedCountdown: 'doesRowObjectNeedCountdown',
  GetObservationMatrix: 'getObservationMatrix',
  GetObservations: 'getObservations',
  GetRowObjects: 'getRowObjects',
  IsRowObjectSaving: 'isRowObjectSaving',
  IsRowObjectUnsaved: 'isRowObjectUnsaved'
}

const GetterFunctions = {
  [GetterNames.DoesRowObjectNeedCountdown]: doesRowObjectNeedCountdown,
  [GetterNames.GetObservationMatrix]: getObservationMatrix,
  [GetterNames.GetObservations]: getObservations,
  [GetterNames.GetRowObjects]: getRowObjects,
  [GetterNames.IsRowObjectSaving]: isRowObjectSaving,
  [GetterNames.IsRowObjectUnsaved]: isRowObjectUnsaved
}

export {
  GetterNames,
  GetterFunctions
}
