import ActionNames from './actionNames'
import loadColumn from './loadColumn'
import loadObservations from './loadObservations'

const ActionFunctions = {
  [ActionNames.LoadColumns]: loadColumn,
  [ActionNames.LoadObservations]: loadObservations
}

export {
  ActionFunctions,
  ActionNames
}
