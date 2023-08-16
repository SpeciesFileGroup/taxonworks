import doesRowObjectNeedCountdown from './doesRowObjectNeedCountdown.js'
import getCharacterStateChecked from './getCharacterStateChecked.js'
import getDescriptor from './getDescriptor.js'
import getDisplayUnscoredRows from './options/GetDisplayUnscoredRows.js'
import getDisplayCharacterStates from './options/GetDisplayCharacterStates.js'
import getDisplayScoredCharacterStates from './options/GetScoredCharacterStates.js'
import getFreeTextValueFor from './getFreeTextValueFor.js'
import getNextColumn from './getNextColumn.js'
import getObservationMatrix from './getObservationMatrix.js'
import getObservations from './getObservations.js'
import getObservationsFor from './getObservationsFor.js'
import getPresenceFor from './getPresenceFor'
import getPreviousColumn from './getPreviousColumn.js'
import getRowObjects from './getRowObjects.js'
import getObservationColumnId from './getObservationColumnId.js'
import getUnits from './getUnits'
import isRowObjectSaving from './isRowObjectSaving.js'
import isRowObjectUnsaved from './isRowObjectUnsaved.js'

const GetterNames = {
  DoesRowObjectNeedCountdown: 'doesRowObjectNeedCountdown',
  GetCharacterStateChecked: 'getCharacterStateChecked',
  GetDescriptor: 'getDescriptor',
  GetDisplayUnscoredRows: 'getDisplayUnscoredRows',
  GetDisplayCharacterStates: 'getDisplayCharacterStates',
  GetDisplayScoredCharacterStates: 'getDisplayScoredCharacterStates',
  GetFreeTextValueFor: 'getFreeTextValueFor',
  GetNextColumn: 'getNextColumn',
  GetObservationColumnId: 'getObservationColumnId',
  GetObservationMatrix: 'getObservationMatrix',
  GetObservations: 'getObservations',
  GetObservationsFor: ' getObservationsFor',
  GetPresenceFor: 'getPresenceFor',
  GetPreviousColumn: 'getPreviousColumn',
  GetRowObjects: 'getRowObjects',
  IsRowObjectSaving: 'isRowObjectSaving',
  IsRowObjectUnsaved: 'isRowObjectUnsaved'
}

const GetterFunctions = {
  [GetterNames.DoesRowObjectNeedCountdown]: doesRowObjectNeedCountdown,
  [GetterNames.GetCharacterStateChecked]: getCharacterStateChecked,
  [GetterNames.GetDescriptor]: getDescriptor,
  [GetterNames.GetDisplayUnscoredRows]: getDisplayUnscoredRows,
  [GetterNames.GetDisplayCharacterStates]: getDisplayCharacterStates,
  [GetterNames.GetDisplayScoredCharacterStates]: getDisplayScoredCharacterStates,
  [GetterNames.GetFreeTextValueFor]: getFreeTextValueFor,
  [GetterNames.GetNextColumn]: getNextColumn,
  [GetterNames.GetObservationColumnId]: getObservationColumnId,
  [GetterNames.GetObservationMatrix]: getObservationMatrix,
  [GetterNames.GetObservationsFor]: getObservationsFor,
  [GetterNames.GetObservations]: getObservations,
  [GetterNames.GetPresenceFor]: getPresenceFor,
  [GetterNames.GetPreviousColumn]: getPreviousColumn,
  [GetterNames.GetPreviousColumn]: getPreviousColumn,
  [GetterNames.GetRowObjects]: getRowObjects,
  [GetterNames.GetUnits]: getUnits,
  [GetterNames.IsRowObjectSaving]: isRowObjectSaving,
  [GetterNames.IsRowObjectUnsaved]: isRowObjectUnsaved
}

export {
  GetterNames,
  GetterFunctions
}
