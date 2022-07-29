import doesRowObjectNeedCountdown from './doesRowObjectNeedCountdown.js'
import getCharacterStateChecked from './getCharacterStateChecked.js'
import getObservationMatrix from './getObservationMatrix.js'
import getObservations from './getObservations.js'
import getObservationsFor from './getObservationsFor.js'
import getRowObjects from './getRowObjects.js'
import getUnits from './getUnits'
import isRowObjectSaving from './isRowObjectSaving.js'
import isRowObjectUnsaved from './isRowObjectUnsaved.js'

const GetterNames = {
  DoesRowObjectNeedCountdown: 'doesRowObjectNeedCountdown',
  GetCharacterStateChecked: 'getCharacterStateChecked',
  GetObservationMatrix: 'getObservationMatrix',
  GetObservations: 'getObservations',
  GetObservationsFor: ' getObservationsFor',
  GetRowObjects: 'getRowObjects',
  IsRowObjectSaving: 'isRowObjectSaving',
  IsRowObjectUnsaved: 'isRowObjectUnsaved'
}

const GetterFunctions = {
  [GetterNames.DoesRowObjectNeedCountdown]: doesRowObjectNeedCountdown,
  [GetterNames.GetCharacterStateChecked]: getCharacterStateChecked,
  [GetterNames.GetObservationMatrix]: getObservationMatrix,
  [GetterNames.GetObservations]: getObservations,
  [GetterNames.GetObservationsFor]: getObservationsFor,
  [GetterNames.GetRowObjects]: getRowObjects,
  [GetterNames.GetUnits]: getUnits,
  [GetterNames.IsRowObjectSaving]: isRowObjectSaving,
  [GetterNames.IsRowObjectUnsaved]: isRowObjectUnsaved
}

export {
  GetterNames,
  GetterFunctions
}
