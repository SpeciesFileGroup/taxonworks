import ActionNames from './actionNames'
import loadBiologicalAssociations from './loadBiologicalAssociations'
import loadInformation from './loadInformation'
import loadCollectionObjects from './loadCollectionObjects'
import loadCollectingEvents from './loadCollectingEvents'
import loadPreferences from './loadPreferences'
import loadAssertedDistributions from './loadAssertedDistributions'
import loadDescendants from './loadDescendants'
import loadTaxonName from './loadTaxonName'
import loadOtus from './loadOtus'
import resetStore from './resetStore'

const ActionFunctions = {
  [ActionNames.LoadBiologicalAssociations]: loadBiologicalAssociations,
  [ActionNames.LoadInformation]: loadInformation,
  [ActionNames.LoadCollectionObjects]: loadCollectionObjects,
  [ActionNames.LoadCollectingEvents]: loadCollectingEvents,
  [ActionNames.LoadPreferences]: loadPreferences,
  [ActionNames.LoadAssertedDistributions]: loadAssertedDistributions,
  [ActionNames.LoadDescendants]: loadDescendants,
  [ActionNames.LoadTaxonName]: loadTaxonName,
  [ActionNames.LoadOtus]: loadOtus,
  [ActionNames.ResetStore]: resetStore
}

export {
  ActionNames,
  ActionFunctions
}
