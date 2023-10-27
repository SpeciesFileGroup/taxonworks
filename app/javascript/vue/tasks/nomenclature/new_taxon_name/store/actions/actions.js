import ActionNames from './actionNames'

import addSubsequentNameForm from './addSubsequentNameForm'
import setParentAndRanks from './setParentAndRanks'
import addTaxonStatus from './addTaxonStatus'
import addTaxonType from './addTaxonType'
import addTaxonRelationship from './addTaxonRelationship'
import addOriginalCombination from './addOriginalCombination'
import cloneTaxon from './cloneTaxon'
import createTaxonName from './createTaxonName'
import createCombination from './createCombination'
import updateTaxonName from './updateTaxonName'
import removeTaxonStatus from './removeTaxonStatus'
import removeTaxonRelationship from './removeTaxonRelationship'
import removeOriginalCombination from './removeOriginalCombination'
import loadCombinations from './loadCombinations'
import loadSoftValidation from './loadSoftValidation'
import loadTaxonName from './loadTaxonName'
import loadTaxonRelationships from './loadTaxonRelationships'
import loadTaxonStatus from './loadTaxonStatus'
import loadRanks from './loadRanks'
import loadStatus from './loadStatus'
import loadRelationships from './loadRelationships'
import loadOriginalCombination from './loadOriginalCombination'
import changeTaxonSource from './changeTaxonSource'
import removeSource from './removeSource'
import removeCombination from './removeCombination'
import updateClassification from './updateClassification'
import updateTaxonRelationship from './updateTaxonRelationship'
import updateTaxonStatus from './updateTaxonStatus'
import updateTaxonType from './updateTaxonType'
import updateSource from './updateSource'

const ActionFunctions = {
  [ActionNames.AddSubsequentNameForm]: addSubsequentNameForm,
  [ActionNames.CreateCombination]: createCombination,
  [ActionNames.LoadCombinations]: loadCombinations,
  [ActionNames.LoadSoftValidation]: loadSoftValidation,
  [ActionNames.LoadTaxonName]: loadTaxonName,
  [ActionNames.LoadRanks]: loadRanks,
  [ActionNames.LoadStatus]: loadStatus,
  [ActionNames.LoadRelationships]: loadRelationships,
  [ActionNames.LoadTaxonRelationships]: loadTaxonRelationships,
  [ActionNames.LoadTaxonStatus]: loadTaxonStatus,
  [ActionNames.LoadOriginalCombination]: loadOriginalCombination,
  [ActionNames.SetParentAndRanks]: setParentAndRanks,
  [ActionNames.AddTaxonStatus]: addTaxonStatus,
  [ActionNames.AddTaxonType]: addTaxonType,
  [ActionNames.AddTaxonRelationship]: addTaxonRelationship,
  [ActionNames.AddOriginalCombination]: addOriginalCombination,
  [ActionNames.CloneTaxon]: cloneTaxon,
  [ActionNames.CreateTaxonName]: createTaxonName,
  [ActionNames.UpdateTaxonName]: updateTaxonName,
  [ActionNames.RemoveCombination]: removeCombination,
  [ActionNames.RemoveTaxonStatus]: removeTaxonStatus,
  [ActionNames.RemoveTaxonRelationship]: removeTaxonRelationship,
  [ActionNames.RemoveOriginalCombination]: removeOriginalCombination,
  [ActionNames.RemoveSource]: removeSource,
  [ActionNames.ChangeTaxonSource]: changeTaxonSource,
  [ActionNames.UpdateClassification]: updateClassification,
  [ActionNames.UpdateTaxonRelationship]: updateTaxonRelationship,
  [ActionNames.UpdateTaxonStatus]: updateTaxonStatus,
  [ActionNames.UpdateTaxonType]: updateTaxonType,
  [ActionNames.UpdateSource]: updateSource
}

export { ActionNames, ActionFunctions }
