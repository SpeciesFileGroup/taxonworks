import ActionNames from './actionNames'
import updateSled from './updateSled'


const ActionFunctions = {
  [ActionNames.UpdateSled]: updateSled
}

export { ActionNames, ActionFunctions }
