import ActionNames from './actionNames'
import loadSledImage from './loadSledImage.js'
import updateSled from './updateSled.js'
import nuke from './nuke.js'
import resetStore from './resetStore.js'
import createSVGBoard from './createSVGBoard.js'

const ActionFunctions = {
  [ActionNames.CreateSVGBoard]: createSVGBoard,
  [ActionNames.LoadSledImage]: loadSledImage,
  [ActionNames.Nuke]: nuke,
  [ActionNames.ResetStore]: resetStore,
  [ActionNames.UpdateSled]: updateSled
}

export {
  ActionNames,
  ActionFunctions
}
