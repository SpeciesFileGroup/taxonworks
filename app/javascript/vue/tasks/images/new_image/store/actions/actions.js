import ActionNames from './actionNames'
import applyAttibutions from './applyAttibutions'
import applyDepictions from './applyDepictions'
import applyTags from './applyTags'
import applyPixelToCentimeter from './applyPixelToCentimeter'
import resetStore from './resetStore'
import removeImage from './removeImage'

const ActionFunctions = {
  [ActionNames.ApplyAttributions]: applyAttibutions,
  [ActionNames.ApplyDepictions]: applyDepictions,
  [ActionNames.ApplyTags]: applyTags,
  [ActionNames.ApplyPixelToCentimeter]: applyPixelToCentimeter,
  [ActionNames.ResetStore]: resetStore,
  [ActionNames.RemoveImage]: removeImage
}

export {
  ActionNames,
  ActionFunctions
}
