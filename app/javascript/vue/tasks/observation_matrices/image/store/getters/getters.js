import getMatrix from './getMatrix'
import getObservations from './getObservations'
import getObservationColumns from './getObservationColumns'
import getObservationMatrix from './getObservationMatrix'
import getObservationRows from './getObservationRows'
import getObservationMoved from './getObservationMoved'
import getIsSaving from './getIsSaving'
import getDepictionMoved from './getDepictionMoved'
import getObservationLanguages from './getObservationLanguages'

const GetterNames = {
  GetMatrix: 'getMatrix',
  GetObservations: 'getObservations',
  GetObservationColumns: 'getObservationColumns',
  GetObservationLanguages: 'getObservationLanguages',
  GetObservationMatrix: 'getObservationMatrix',
  GetObservationRows: 'getObservationRows',
  GetObservationMoved: 'getObservationMoved',
  GetIsSaving: 'getIsSaving',
  GetDepictionMoved: 'getDepictionMoved'
}

const GetterFunctions = {
  [GetterNames.GetMatrix]: getMatrix,
  [GetterNames.GetObservations]: getObservations,
  [GetterNames.GetObservationColumns]: getObservationColumns,
  [GetterNames.GetObservationLanguages]: getObservationLanguages,
  [GetterNames.GetObservationMatrix]: getObservationMatrix,
  [GetterNames.GetObservationRows]: getObservationRows,
  [GetterNames.GetObservationMoved]: getObservationMoved,
  [GetterNames.GetIsSaving]: getIsSaving,
  [GetterNames.GetDepictionMoved]: getDepictionMoved
}

export {
  GetterNames,
  GetterFunctions
}