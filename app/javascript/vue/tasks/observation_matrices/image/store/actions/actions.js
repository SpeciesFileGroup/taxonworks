import ActionNames from './actionNames'
import createNewColumn from './createNewColumn'
import createObservation from './createObservation'
import loadObservationMatrix from './loadObservationMatrix'
import loadOtuDepictions from './loadOtuDepictions'

const ActionFunctions = {
  [ActionNames.CreateNewColumn]: createNewColumn,
  [ActionNames.CreateObservation]: createObservation,
  [ActionNames.LoadObservationMatrix]: loadObservationMatrix,
  [ActionNames.LoadOtuDepictions]: loadOtuDepictions
}

export {
  ActionNames,
  ActionFunctions
}
