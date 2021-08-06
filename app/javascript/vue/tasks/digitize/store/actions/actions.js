import ActionNames from './actionNames'

import addToContainer from './AddToContainer'
import getCOCitations from './getCOCitations'
import getCollectionEvent from './getCollectionEvent'
import getCollectionObject from './getCollectionObject'
import getIdentifier from './getIdentifier'
import getIdentifiers from './getIdentifiers'
import getLabels from './getLabels'
import getNamespace from './getNamespace'
import getTaxon from './getTaxon'
import getTaxonDeterminations from './getTaxonDeterminations'
import getTypeMaterial from './getTypeMaterial'
import loadBiologicalAssociations from './loadBiologicalAssociations'
import loadContainer from './loadContainer'
import loadDigitalization from './loadDigitalization'
import loadSoftValidations from './loadSoftValidations'
import newCollectionEvent from './newCollectionEvent'
import newCollectionObject from './newCollectionObject'
import newIdentifier from './newIdentifier'
import newLabel from './newLabel'
import newTaxonDetermination from './newTaxonDetermination'
import newTypeMaterial from './newTypeMaterial'
import removeCOCitation from './removeCOCitation'
import removeCollectionObject from './removeCollectionObject'
import removeContainer from './removeContainer'
import removeContainerItem from './removeContainerItem'
import removeDepictionsByImageId from './removeDepictionsByImageId'
import removeTaxonDetermination from './removeTaxonDetermination'
import removeTypeMaterial from './removeTypeMaterial'
import resetWithDefault from './resetWithDefault'
import saveCOCitations from './saveCOCitations'
import saveCollectionEvent from './saveCollectionEvent'
import saveCollectionObject from './saveCollectionObject'
import saveContainer from './saveContainer'
import saveContainerItem from './saveContainerItem'
import saveDetermination from './saveDetermination'
import saveDeterminations from './saveDeterminations'
import saveDigitalization from './saveDigitalization'
import saveIdentifier from './saveIdentifier'
import saveLabel from './saveLabel'
import saveTypeMaterial from './saveTypeMaterial'

const ActionFunctions = {
  [ActionNames.AddToContainer]: addToContainer,
  [ActionNames.GetCollectionEvent]: getCollectionEvent,
  [ActionNames.GetCollectionObject]: getCollectionObject,
  [ActionNames.GetIdentifier]: getIdentifier,
  [ActionNames.GetIdentifiers]: getIdentifiers,
  [ActionNames.GetLabels]: getLabels,
  [ActionNames.GetNamespace]: getNamespace,
  [ActionNames.GetTaxonDeterminations]: getTaxonDeterminations,
  [ActionNames.GetTaxon]: getTaxon,
  [ActionNames.GetTypeMaterial]: getTypeMaterial,
  [ActionNames.LoadContainer]: loadContainer,
  [ActionNames.GetCOCitations]: getCOCitations,
  [ActionNames.LoadDigitalization]: loadDigitalization,
  [ActionNames.NewCollectionEvent]: newCollectionEvent,
  [ActionNames.NewCollectionObject]: newCollectionObject,
  [ActionNames.NewIdentifier]: newIdentifier,
  [ActionNames.NewLabel]: newLabel,
  [ActionNames.NewTaxonDetermination]: newTaxonDetermination,
  [ActionNames.NewTypeMaterial]: newTypeMaterial,
  [ActionNames.RemoveCOCitation]: removeCOCitation,
  [ActionNames.RemoveCollectionObject]: removeCollectionObject,
  [ActionNames.RemoveContainer]: removeContainer,
  [ActionNames.RemoveContainerItem]: removeContainerItem,
  [ActionNames.RemoveDepictionsByImageId]: removeDepictionsByImageId,
  [ActionNames.RemoveTaxonDetermination]: removeTaxonDetermination,
  [ActionNames.RemoveTypeMaterial]: removeTypeMaterial,
  [ActionNames.ResetWithDefault]: resetWithDefault,
  [ActionNames.SaveCOCitations]: saveCOCitations,
  [ActionNames.SaveCollectionEvent]: saveCollectionEvent,
  [ActionNames.SaveCollectionObject]: saveCollectionObject,
  [ActionNames.SaveContainerItem]: saveContainerItem,
  [ActionNames.SaveContainer]: saveContainer,
  [ActionNames.SaveDetermination]: saveDetermination,
  [ActionNames.SaveDeterminations]: saveDeterminations,
  [ActionNames.SaveDigitalization]: saveDigitalization,
  [ActionNames.SaveIdentifier]: saveIdentifier,
  [ActionNames.SaveLabel]: saveLabel,
  [ActionNames.SaveTypeMaterial]: saveTypeMaterial,
  [ActionNames.LoadSoftValidations]: loadSoftValidations,
  [ActionNames.LoadBiologicalAssociations]: loadBiologicalAssociations
}

export {
  ActionNames,
  ActionFunctions
}
