import setParentAndRanks from './setParentAndRanks'
import addTaxonStatus from './addTaxonStatus'
import addTaxonType from './addTaxonType'
import addTaxonRelationship from './addTaxonRelationship'
import addOriginalCombination from './addOriginalCombination'
import cloneTaxon from './cloneTaxon'
import createTaxonName from './createTaxonName'
import updateTaxonName from './updateTaxonName'
import removeTaxonStatus from './removeTaxonStatus'
import removeTaxonRelationship from './removeTaxonRelationship'
import removeOriginalCombination from './removeOriginalCombination'
import loadSoftValidation from './loadSoftValidation'
import loadTaxonName from './loadTaxonName'
import loadTaxonRelationships from './loadTaxonRelationships'
import loadTaxonStatus from './loadTaxonStatus'
import loadRanks from './loadRanks'
import loadStatus from './loadStatus'
import loadRelationships from './loadRelationships'
import changeTaxonSource from './changeTaxonSource'
import removeSource from './removeSource'
import updateClassification from './updateClassification'
import updateTaxonRelationship from './updateTaxonRelationship'
import updateTaxonStatus from './updateTaxonStatus'
import updateTaxonType from './updateTaxonType'
import updateSource from './updateSource'

const ActionNames = {
  SetParentAndRanks: 'setParentAndRanks',
  AddTaxonStatus: 'addTaxonStatus',
  AddTaxonType: 'addTaxonType',
  AddTaxonRelationship: 'addTaxonRelationship',
  AddOriginalCombination: 'addOriginalCombination',
  CloneTaxon: 'cloneTaxon',
  CreateTaxonName: 'createTaxonName',
  UpdateTaxonName: 'updateTaxonName',
  RemoveTaxonStatus: 'removeTaxonStatus',
  RemoveTaxonRelationship: 'removeTaxonRelationship',
  RemoveOriginalCombination: 'removeOriginalCombination',
  LoadSoftValidation: 'loadSoftValidation',
  LoadTaxonName: 'loadTaxonName',
  LoadTaxonRelationships: 'loadTaxonRelationships',
  LoadTaxonStatus: 'loadTaxonStatus',
  LoadRanks: 'loadRanks',
  LoadStatus: 'loadStatus',
  LoadRelationships: 'loadRelationships',
  ChangeTaxonSource: 'changeTaxonSource',
  RemoveSource: 'removeSource',
  UpdateClassification: 'updateClassification',
  UpdateTaxonRelationship: 'updateTaxonRelationship',
  UpdateTaxonStatus: 'updateTaxonStatus',
  UpdateTaxonType: 'updateTaxonType',
  UpdateSource: 'updateSource'
}

const ActionFunctions = {
  [ActionNames.LoadSoftValidation]: loadSoftValidation,
  [ActionNames.LoadTaxonName]: loadTaxonName,
  [ActionNames.LoadRanks]: loadRanks,
  [ActionNames.LoadStatus]: loadStatus,
  [ActionNames.LoadRelationships]: loadRelationships,
  [ActionNames.LoadTaxonRelationships]: loadTaxonRelationships,
  [ActionNames.LoadTaxonStatus]: loadTaxonStatus,
  [ActionNames.SetParentAndRanks]: setParentAndRanks,
  [ActionNames.AddTaxonStatus]: addTaxonStatus,
  [ActionNames.AddTaxonType]: addTaxonType,
  [ActionNames.AddTaxonRelationship]: addTaxonRelationship,
  [ActionNames.AddOriginalCombination]: addOriginalCombination,
  [ActionNames.CloneTaxon]: cloneTaxon,
  [ActionNames.CreateTaxonName]: createTaxonName,
  [ActionNames.UpdateTaxonName]: updateTaxonName,
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

export {
  ActionNames,
  ActionFunctions
}
