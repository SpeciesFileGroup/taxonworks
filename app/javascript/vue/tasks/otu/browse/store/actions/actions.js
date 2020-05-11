import ActionNames from './actionNames'
import loadInformation from './loadInformation'
import loadCollectionObjects from './loadCollectionObjects'
import loadCollectingEvents from './loadCollectingEvents'

const ActionFunctions = {
  [ActionNames.LoadInformation]: loadInformation,
  [ActionNames.LoadCollectionObjects]: loadCollectionObjects,
  [ActionNames.LoadCollectingEvents]: loadCollectingEvents
}

export {
  ActionNames,
  ActionFunctions
}
