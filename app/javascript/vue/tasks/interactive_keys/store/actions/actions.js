import ActionNames from './actionNames'
import loadObservationMatrix from './loadObservationMatrix'
import loadUpdatedRemaining from './loadUpdatedRemaining'

const ActionFunctions = {
  [ActionNames.LoadObservationMatrix]: loadObservationMatrix,
  [ActionNames.LoadUpdatedRemaining]: loadUpdatedRemaining
}

export {
  ActionNames,
  ActionFunctions
}
