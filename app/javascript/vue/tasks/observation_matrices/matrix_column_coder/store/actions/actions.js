import ActionNames from './actionNames'
import loadColumn from './loadColumn'
import loadObservations from './loadObservations'
import loadUnits from './loadUnits'

const ActionFunctions = {
  [ActionNames.LoadColumns]: loadColumn,
  [ActionNames.LoadObservations]: loadObservations,
  [ActionNames.LoadUnits]: loadUnits
}

export {
  ActionFunctions,
  ActionNames
}
