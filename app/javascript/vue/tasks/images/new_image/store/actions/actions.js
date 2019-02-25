import ActionNames from './actionNames'
import applyAttibutions from './applyAttibutions'
import applyDepictions from './applyDepictions'
import resetStore from './resetStore'
import removeImage from './removeImage'

const ActionFunctions = {
  [ActionNames.ApplyAttributions]: applyAttibutions,
  [ActionNames.ApplyDepictions]: applyDepictions,
  [ActionNames.ResetStore]: resetStore,
  [ActionNames.RemoveImage]: removeImage
}

export { ActionNames, ActionFunctions }
