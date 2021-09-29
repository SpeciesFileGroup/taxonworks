import getCollectionObjects from './getCollectionObjects.js'
import getObservationMatrix from './getObservationMatrix.js'
import getObservations from './getObservations.js'
import getOtus from './getOtus.js'

const GetterNames = {
  GetCollectionObjects: 'getCollectionObjects',
  GetObservationMatrix: 'getObservationMatrix',
  GetObservations: 'getObservations',
  GetOtus: 'getOtus'
}

const GetterFunctions = {
  [GetterNames.GetCollectionObjects]: getCollectionObjects,
  [GetterNames.GetObservationMatrix]: getObservationMatrix,
  [GetterNames.GetObservations]: getObservations,
  [GetterNames.GetOtus]: getOtus
}

export {
  GetterNames,
  GetterFunctions
}
