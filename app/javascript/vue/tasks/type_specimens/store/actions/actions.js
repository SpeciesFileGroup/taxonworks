import ActionNames from './actionNames'
import loadTypeMaterial from './loadTypeMaterial'
import loadTaxonName from './loadTaxonName'
import loadTypeMaterials from './loadTypeMaterials'
import loadSoftValidations from './loadSoftValidations'
import createTypeMaterial from './createTypeMaterial'
import removeTypeSpecimen from './removeTypeSpecimen'
import updateTypeSpecimen from './updateTypeSpecimen'
import setNewTypeMaterial from './setNewTypeMaterial'
import updateCollectionObject from './updateCollectionObject'
import setTypeMaterialCO from './setTypeMaterialCO'

const ActionFunctions = {
  [ActionNames.LoadTypeMaterial]: loadTypeMaterial,
  [ActionNames.LoadTypeMaterials]: loadTypeMaterials,
  [ActionNames.LoadTaxonName]: loadTaxonName,
  [ActionNames.LoadSoftValidations]: loadSoftValidations,
  [ActionNames.CreateTypeMaterial]: createTypeMaterial,
  [ActionNames.RemoveTypeSpecimen]: removeTypeSpecimen,
  [ActionNames.UpdateTypeSpecimen]: updateTypeSpecimen,
  [ActionNames.SetNewTypeMaterial]: setNewTypeMaterial,
  [ActionNames.UpdateCollectionObject]: updateCollectionObject,
  [ActionNames.SetTypeMaterialCO]: setTypeMaterialCO
}

export { ActionNames, ActionFunctions }
