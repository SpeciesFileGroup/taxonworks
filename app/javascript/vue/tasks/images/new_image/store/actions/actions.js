import ActionNames from './actionNames'
import applyAttibutions from './applyAttibutions'
import applyDepictions from './applyDepictions'
import applyPixelToCentimeter from './applyPixelToCentimeter'
import applySource from './applySource'
import applyTags from './applyTags'
import clearImages from './clearImages'
import removeImage from './removeImage'
import resetStore from './resetStore'

const ActionFunctions = {
  [ActionNames.ApplyAttributions]: applyAttibutions,
  [ActionNames.ApplyDepictions]: applyDepictions,
  [ActionNames.ApplyPixelToCentimeter]: applyPixelToCentimeter,
  [ActionNames.ApplySource]: applySource,
  [ActionNames.ApplyTags]: applyTags,
  [ActionNames.ClearImages]: clearImages,
  [ActionNames.RemoveImage]: removeImage,
  [ActionNames.ResetStore]: resetStore
}

export { ActionNames, ActionFunctions }
