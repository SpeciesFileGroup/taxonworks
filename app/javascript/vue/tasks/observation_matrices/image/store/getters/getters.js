import getMatrix from './getMatrix'
import getObservations from './getObservations'
import getObservationColumns from './getObservationColumns'
import getObservationMatrix from './getObservationMatrix'
import getObservationRows from './getObservationRows'
import getObservationMoved from './getObservationMoved'
import getIsSaving from './getIsSaving'
import getDepictionMoved from './getDepictionMoved'
import getObservationLanguages from './getObservationLanguages'
import getPagination from './getPagination.js'
import getIsLoading from './getIsLoading.js'
import IsClone from './isClone.js'

const GetterNames = {
  GetMatrix: 'getMatrix',
  GetObservations: 'getObservations',
  GetObservationColumns: 'getObservationColumns',
  GetObservationLanguages: 'getObservationLanguages',
  GetObservationMatrix: 'getObservationMatrix',
  GetObservationRows: 'getObservationRows',
  GetObservationMoved: 'getObservationMoved',
  GetIsSaving: 'getIsSaving',
  GetDepictionMoved: 'getDepictionMoved',
  GetPagination: 'getPagination',
  GetIsLoading: 'getIsLoading',
  IsClone: 'isClone'
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
  [GetterNames.GetDepictionMoved]: getDepictionMoved,
  [GetterNames.GetPagination]: getPagination,
  [GetterNames.GetIsLoading]: getIsLoading,
  [GetterNames.IsClone]: IsClone
}

export { GetterNames, GetterFunctions }
