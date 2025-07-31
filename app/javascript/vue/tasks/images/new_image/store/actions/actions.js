import ActionNames from './actionNames'
import applyAttibutions from './applyAttibutions'
import applyDepictions from './applyDepictions'
import applyPixelToCentimeter from './applyPixelToCentimeter'
import applySource from './applySource'
import applyTags from './applyTags'
import removeImage from './removeImage'
import resetStore from './resetStore'
import setAllApplied from './setAllApplied'

const ActionFunctions = {
  [ActionNames.ApplyAttributions]: applyAttibutions,
  [ActionNames.ApplyDepictions]: applyDepictions,
  [ActionNames.ApplyPixelToCentimeter]: applyPixelToCentimeter,
  [ActionNames.ApplySource]: applySource,
  [ActionNames.ApplyTags]: applyTags,
  [ActionNames.RemoveImage]: removeImage,
  [ActionNames.ResetStore]: resetStore,
  [ActionNames.SetAllApplied]: setAllApplied
}

export { ActionNames, ActionFunctions }
