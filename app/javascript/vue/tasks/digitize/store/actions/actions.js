import ActionNames from './actionNames'

import addToContainer from './AddToContainer'
import addTypeSpecimen from './addTypeSpecimen'
import cloneCollectingEvent from './cloneCollectingEvent'
import getCOCitations from './getCOCitations'
import getCollectingEvent from './getCollectingEvent'
import getCollectionObject from './getCollectionObject'
import getLabels from './getLabels'
import getNamespace from './getNamespace'
import setTypeMaterial from './setTypeMaterial'
import setTypeMaterialTaxonName from './setTypeMaterialTaxonName'
import loadTypeSpecimens from './loadTypeSpecimens'
import loadBiologicalAssociations from './loadBiologicalAssociations'
import loadContainer from './loadContainer'
import loadDigitalization from './loadDigitalization'
import loadSoftValidations from './loadSoftValidations'
import loadGeoreferences from './loadGeoreferences'
import newCollectingEvent from './newCollectingEvent'
import newCollectionObject from './newCollectionObject'
import newIdentifier from './newIdentifier'
import newLabel from './newLabel'
import newTypeMaterial from './newTypeMaterial'
import removeCOCitation from './removeCOCitation'
import removeCollectionObject from './removeCollectionObject'
import removeContainer from './removeContainer'
import removeContainerItem from './removeContainerItem'
import removeDepictionsByImageId from './removeDepictionsByImageId'
import removeTypeMaterial from './removeTypeMaterial'
import resetWithDefault from './resetWithDefault'
import saveCOCitations from './saveCOCitations'
import saveCollectingEvent from './saveCollectingEvent'
import saveCollectionObject from './saveCollectionObject'
import saveContainer from './saveContainer'
import saveContainerItem from './saveContainerItem'
import saveDigitalization from './saveDigitalization'
import saveLabel from './saveLabel'
import saveTypeMaterial from './saveTypeMaterial'
import saveBiologicalAssociations from './saveBiologicalAssociations'
import updateLayoutPreferences from './updateLayoutPreferences'
import updateLastChange from './updateLastChange'
import updateCEChange from './updateCEChange'
import resetSource from './resetStore'

const ActionFunctions = {
  [ActionNames.AddToContainer]: addToContainer,
  [ActionNames.AddTypeSpecimen]: addTypeSpecimen,
  [ActionNames.CloneCollectingEvent]: cloneCollectingEvent,
  [ActionNames.GetCollectingEvent]: getCollectingEvent,
  [ActionNames.GetCollectionObject]: getCollectionObject,
  [ActionNames.GetLabels]: getLabels,
  [ActionNames.GetNamespace]: getNamespace,
  [ActionNames.SetTypeMaterial]: setTypeMaterial,
  [ActionNames.SetTypeMaterialTaxonName]: setTypeMaterialTaxonName,
  [ActionNames.LoadTypeSpecimens]: loadTypeSpecimens,
  [ActionNames.LoadContainer]: loadContainer,
  [ActionNames.GetCOCitations]: getCOCitations,
  [ActionNames.LoadDigitalization]: loadDigitalization,
  [ActionNames.NewCollectingEvent]: newCollectingEvent,
  [ActionNames.NewCollectionObject]: newCollectionObject,
  [ActionNames.NewIdentifier]: newIdentifier,
  [ActionNames.NewLabel]: newLabel,
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
  [ActionNames.SaveCollectingEvent]: saveCollectingEvent,
  [ActionNames.SaveCollectionObject]: saveCollectionObject,
  [ActionNames.SaveContainerItem]: saveContainerItem,
  [ActionNames.SaveContainer]: saveContainer,
  [ActionNames.SaveDigitalization]: saveDigitalization,
  [ActionNames.SaveLabel]: saveLabel,
  [ActionNames.SaveTypeMaterial]: saveTypeMaterial,
  [ActionNames.SaveBiologicalAssociations]: saveBiologicalAssociations,
  [ActionNames.LoadSoftValidations]: loadSoftValidations,
  [ActionNames.LoadBiologicalAssociations]: loadBiologicalAssociations,
  [ActionNames.LoadGeoreferences]: loadGeoreferences,
  [ActionNames.UpdateLayoutPreferences]: updateLayoutPreferences,
  [ActionNames.UpdateLastChange]: updateLastChange,
  [ActionNames.UpdateCEChange]: updateCEChange
}

export { ActionNames, ActionFunctions }
