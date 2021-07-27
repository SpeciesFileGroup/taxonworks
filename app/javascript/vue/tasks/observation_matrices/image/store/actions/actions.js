import ActionNames from './actionNames'
import createObservation from './createObservation'
import loadObservationMatrix from './loadObservationMatrix'
import loadOtuDepictions from './loadOtuDepictions'

const ActionFunctions = {
  [ActionNames.CreateObservation]: createObservation,
  [ActionNames.LoadObservationMatrix]: loadObservationMatrix,
  [ActionNames.LoadOtuDepictions]: loadOtuDepictions
}

export {
  ActionNames,
  ActionFunctions
}
