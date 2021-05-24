import ActionNames from './actionNames'
import createObservation from './createObservation'
import loadObservationMatrix from './loadObservationMatrix'

const ActionFunctions = {
  [ActionNames.CreateObservation]: createObservation,
  [ActionNames.LoadObservationMatrix]: loadObservationMatrix
}

export {
  ActionNames,
  ActionFunctions
}
