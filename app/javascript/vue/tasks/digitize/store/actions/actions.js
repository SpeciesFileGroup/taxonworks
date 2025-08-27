import ActionNames from './actionNames'

import addToContainer from './AddToContainer'
import addTypeSpecimen from './addTypeSpecimen'
import getCOCitations from './getCOCitations'
import getCollectionObject from './getCollectionObject'
import setTypeMaterial from './setTypeMaterial'
import setTypeMaterialTaxonName from './setTypeMaterialTaxonName'
import loadTypeSpecimens from './loadTypeSpecimens'
import loadContainer from './loadContainer'
import loadDigitalization from './loadDigitalization'
import loadSoftValidations from './loadSoftValidations'
import newCollectionObject from './newCollectionObject'
import newTypeMaterial from './newTypeMaterial'
import removeCOCitation from './removeCOCitation'
import removeCollectionObject from './removeCollectionObject'
import removeContainer from './removeContainer'
import removeContainerItem from './removeContainerItem'
import removeDepictionsByImageId from './removeDepictionsByImageId'
import removeTypeMaterial from './removeTypeMaterial'
import resetWithDefault from './resetWithDefault'
import saveCOCitations from './saveCOCitations'
import saveCollectionObject from './saveCollectionObject'
import saveContainer from './saveContainer'
import saveContainerItem from './saveContainerItem'
import saveDigitalization from './saveDigitalization'
import saveTypeMaterial from './saveTypeMaterial'
import updateLayoutPreferences from './updateLayoutPreferences'
import updateLastChange from './updateLastChange'
import updateCEChange from './updateCEChange'
import resetSource from './resetStore'

const ActionFunctions = {
  [ActionNames.AddToContainer]: addToContainer,
  [ActionNames.AddTypeSpecimen]: addTypeSpecimen,
  [ActionNames.GetCollectionObject]: getCollectionObject,
  [ActionNames.SetTypeMaterial]: setTypeMaterial,
  [ActionNames.SetTypeMaterialTaxonName]: setTypeMaterialTaxonName,
  [ActionNames.LoadTypeSpecimens]: loadTypeSpecimens,
  [ActionNames.LoadContainer]: loadContainer,
  [ActionNames.GetCOCitations]: getCOCitations,
  [ActionNames.LoadDigitalization]: loadDigitalization,
  [ActionNames.NewCollectionObject]: newCollectionObject,
  [ActionNames.NewTypeMaterial]: newTypeMaterial,
  [ActionNames.RemoveCOCitation]: removeCOCitation,
  [ActionNames.RemoveCollectionObject]: removeCollectionObject,
  [ActionNames.RemoveContainer]: removeContainer,
  [ActionNames.RemoveContainerItem]: removeContainerItem,
  [ActionNames.RemoveDepictionsByImageId]: removeDepictionsByImageId,
  [ActionNames.RemoveTypeMaterial]: removeTypeMaterial,
  [ActionNames.ResetStore]: resetSource,
  [ActionNames.ResetWithDefault]: resetWithDefault,
  [ActionNames.SaveCOCitations]: saveCOCitations,
  [ActionNames.SaveCollectionObject]: saveCollectionObject,
  [ActionNames.SaveContainerItem]: saveContainerItem,
  [ActionNames.SaveContainer]: saveContainer,
  [ActionNames.SaveDigitalization]: saveDigitalization,
  [ActionNames.SaveTypeMaterial]: saveTypeMaterial,
  [ActionNames.LoadSoftValidations]: loadSoftValidations,
  [ActionNames.UpdateLayoutPreferences]: updateLayoutPreferences,
  [ActionNames.UpdateLastChange]: updateLastChange,
  [ActionNames.UpdateCEChange]: updateCEChange
}

export { ActionNames, ActionFunctions }
