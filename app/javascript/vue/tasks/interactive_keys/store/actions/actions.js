import ActionNames from './actionNames'
import loadObservationMatrix from './loadObservationMatrix'

const ActionFunctions = {
  [ActionNames.LoadObservationMatrix]: loadObservationMatrix
}

export {
  ActionNames,
  ActionFunctions
}
