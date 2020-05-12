import ActionNames from './actionNames'
import loadInformation from './loadInformation'
import loadCollectionObjects from './loadCollectionObjects'
import loadCollectingEvents from './loadCollectingEvents'
import loadPreferences from './loadPreferences'

const ActionFunctions = {
  [ActionNames.LoadInformation]: loadInformation,
  [ActionNames.LoadCollectionObjects]: loadCollectionObjects,
  [ActionNames.LoadCollectingEvents]: loadCollectingEvents,
  [ActionNames.LoadPreferences]: loadPreferences
}

export {
  ActionNames,
  ActionFunctions
}
