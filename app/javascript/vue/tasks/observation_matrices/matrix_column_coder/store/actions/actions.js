import ActionNames from './actionNames'
import loadColumn from './loadColumn'
import loadObservations from './loadObservations'
import loadUnits from './loadUnits'
import saveObservationsFor from './saveObservationsFor'
import createObservation from './createObservation'
import updateObservation from './updateObservation'
import removeObservation from './removeObservation'

const ActionFunctions = {
  [ActionNames.LoadColumns]: loadColumn,
  [ActionNames.LoadObservations]: loadObservations,
  [ActionNames.LoadUnits]: loadUnits,
  [ActionNames.SaveObservationsFor]: saveObservationsFor,
  [ActionNames.CreateObservation]: createObservation,
  [ActionNames.UpdateObservation]: updateObservation,
  [ActionNames.RemoveObservation]: removeObservation
}

export {
  ActionFunctions,
  ActionNames
}
