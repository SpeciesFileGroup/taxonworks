import ActionNames from './actionNames'
import updateSled from './updateSled'
import nuke from './nuke'
import resetStore from './resetStore'

const ActionFunctions = {
  [ActionNames.UpdateSled]: updateSled,
  [ActionNames.Nuke]: nuke,
  [ActionNames.ResetStore]: resetStore
}

export { ActionNames, ActionFunctions }
