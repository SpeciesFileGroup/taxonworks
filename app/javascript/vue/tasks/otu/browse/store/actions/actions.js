import ActionNames from './actionNames'
import loadBiologicalAssociations from './loadBiologicalAssociations'
import loadInformation from './loadInformation'
import loadCollectionObjects from './loadCollectionObjects'
import loadCollectingEvents from './loadCollectingEvents'
import loadCommonNames from './loadCommonNames'
import loadDepictions from './loadDepictions'
import loadDistribution from './loadDistribution'
import loadFieldOccurrences from './loadFieldOccurrences'
import loadPreferences from './loadPreferences'
import loadAssertedDistributions from './loadAssertedDistributions'
import loadDescendants from './loadDescendants'
import loadTaxonName from './loadTaxonName'
import loadObservationDepictions from './loadObservationDepictions'
import loadOtus from './loadOtus'
import resetStore from './resetStore'

const ActionFunctions = {
  [ActionNames.LoadAssertedDistributions]: loadAssertedDistributions,
  [ActionNames.LoadBiologicalAssociations]: loadBiologicalAssociations,
  [ActionNames.LoadCollectingEvents]: loadCollectingEvents,
  [ActionNames.LoadCollectionObjects]: loadCollectionObjects,
  [ActionNames.LoadCommonNames]: loadCommonNames,
  [ActionNames.LoadDepictions]: loadDepictions,
  [ActionNames.LoadDescendants]: loadDescendants,
  [ActionNames.LoadDistribution]: loadDistribution,
  [ActionNames.LoadInformation]: loadInformation,
  [ActionNames.LoadFieldOccurrences]: loadFieldOccurrences,
  [ActionNames.LoadObservationDepictions]: loadObservationDepictions,
  [ActionNames.LoadOtus]: loadOtus,
  [ActionNames.LoadPreferences]: loadPreferences,
  [ActionNames.LoadTaxonName]: loadTaxonName,
  [ActionNames.ResetStore]: resetStore
}

export { ActionNames, ActionFunctions }
