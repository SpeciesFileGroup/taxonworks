import ActionNames from './actionNames'
import loadInformation from './loadInformation'
import loadCollectionObjects from './loadCollectionObjects'
import loadCollectingEvents from './loadCollectingEvents'
import loadPreferences from './loadPreferences'
import loadAssertedDistributions from './loadAssertedDistributions'
import loadDescendants from './loadDescendants'
import loadTaxonName from './loadTaxonName'

const ActionFunctions = {
  [ActionNames.LoadInformation]: loadInformation,
  [ActionNames.LoadCollectionObjects]: loadCollectionObjects,
  [ActionNames.LoadCollectingEvents]: loadCollectingEvents,
  [ActionNames.LoadPreferences]: loadPreferences,
  [ActionNames.LoadAssertedDistributions]: loadAssertedDistributions,
  [ActionNames.LoadDescendants]: loadDescendants,
  [ActionNames.LoadTaxonName]: loadTaxonName
}

export {
  ActionNames,
  ActionFunctions
}
