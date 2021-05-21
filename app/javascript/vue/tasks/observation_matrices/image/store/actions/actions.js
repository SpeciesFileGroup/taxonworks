import ActionNames from './actionNames'
import createObservation from './createObservation'

const ActionFunctions = {
  [ActionNames.CreateObservation]: createObservation,
}

export { ActionNames, ActionFunctions }