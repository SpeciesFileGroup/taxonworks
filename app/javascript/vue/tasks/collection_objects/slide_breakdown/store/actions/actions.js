import ActionNames from './actionNames'
import updateSled from './updateSled'
import nuke from './nuke'


const ActionFunctions = {
  [ActionNames.UpdateSled]: updateSled,
  [ActionNames.Nuke]: nuke
}

export { ActionNames, ActionFunctions }
