import ActionNames from './actionNames'
import createDepiction from './createDepiction'
import createNewColumn from './createNewColumn'
import createObservation from './createObservation'
import loadObservationMatrix from './loadObservationMatrix'
import loadOtuDepictions from './loadOtuDepictions'
import moveDepiction from './moveDepiction'

const ActionFunctions = {
  [ActionNames.CreateDepiction]: createDepiction,
  [ActionNames.CreateNewColumn]: createNewColumn,
  [ActionNames.CreateObservation]: createObservation,
  [ActionNames.LoadObservationMatrix]: loadObservationMatrix,
  [ActionNames.LoadOtuDepictions]: loadOtuDepictions,
  [ActionNames.MoveDepiction]: moveDepiction
}

export { ActionNames, ActionFunctions }
