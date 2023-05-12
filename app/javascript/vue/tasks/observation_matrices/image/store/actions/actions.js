import ActionNames from './actionNames'
import createNewColumn from './createNewColumn'
import createObservation from './createObservation'
import loadObservationMatrix from './loadObservationMatrix'
import loadOtuDepictions from './loadOtuDepictions'
import moveDepiction from './moveDepiction'

const ActionFunctions = {
  [ActionNames.CreateNewColumn]: createNewColumn,
  [ActionNames.CreateObservation]: createObservation,
  [ActionNames.LoadObservationMatrix]: loadObservationMatrix,
  [ActionNames.LoadOtuDepictions]: loadOtuDepictions,
  [ActionNames.MoveDepiction]: moveDepiction
}

export {
  ActionNames,
  ActionFunctions
}
