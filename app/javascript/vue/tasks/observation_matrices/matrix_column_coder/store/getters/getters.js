import doesRowObjectNeedCountdown from './doesRowObjectNeedCountdown.js'
import getCharacterStateChecked from './getCharacterStateChecked.js'
import getFreeTextValueFor from './getFreeTextValueFor.js'
import getObservationMatrix from './getObservationMatrix.js'
import getObservations from './getObservations.js'
import getObservationsFor from './getObservationsFor.js'
import getRowObjects from './getRowObjects.js'
import getPresenceFor from './getPresenceFor'
import getUnits from './getUnits'
import isRowObjectSaving from './isRowObjectSaving.js'
import isRowObjectUnsaved from './isRowObjectUnsaved.js'

const GetterNames = {
  DoesRowObjectNeedCountdown: 'doesRowObjectNeedCountdown',
  GetCharacterStateChecked: 'getCharacterStateChecked',
  GetFreeTextValueFor: 'getFreeTextValueFor',
  GetObservationMatrix: 'getObservationMatrix',
  GetObservations: 'getObservations',
  GetObservationsFor: ' getObservationsFor',
  GetRowObjects: 'getRowObjects',
  GetPresenceFor: 'getPresenceFor',
  IsRowObjectSaving: 'isRowObjectSaving',
  IsRowObjectUnsaved: 'isRowObjectUnsaved'
}

const GetterFunctions = {
  [GetterNames.DoesRowObjectNeedCountdown]: doesRowObjectNeedCountdown,
  [GetterNames.GetCharacterStateChecked]: getCharacterStateChecked,
  [GetterNames.GetFreeTextValueFor]: getFreeTextValueFor,
  [GetterNames.GetObservationMatrix]: getObservationMatrix,
  [GetterNames.GetObservations]: getObservations,
  [GetterNames.GetObservationsFor]: getObservationsFor,
  [GetterNames.GetRowObjects]: getRowObjects,
  [GetterNames.GetUnits]: getUnits,
  [GetterNames.GetPresenceFor]: getPresenceFor,
  [GetterNames.IsRowObjectSaving]: isRowObjectSaving,
  [GetterNames.IsRowObjectUnsaved]: isRowObjectUnsaved
}

export {
  GetterNames,
  GetterFunctions
}
