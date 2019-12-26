import ActionNames from './actionNames'

import loadDigitalization from './loadDigitalization'
import loadContainer from './loadContainer'
import getTaxon from './getTaxon'
import getLabels from './getLabels'
import getNamespace from './getNamespace'
import getTypeMaterial from './getTypeMaterial'
import getTaxonDeterminations from './getTaxonDeterminations'
import getCollectionObject from './getCollectionObject'
import getCollectionEvent from './getCollectionEvent'
import getIdentifier from './getIdentifier'
import getIdentifiers from './getIdentifiers'
import saveDigitalization from './saveDigitalization'
import saveIdentifier from './saveIdentifier'
import saveCollectionObject from './saveCollectionObject'
import saveCollectionEvent from './saveCollectionEvent'
import saveTypeMaterial from './saveTypeMaterial'
import saveDetermination from './saveDetermination'
import saveDeterminations from './saveDeterminations'
import saveContainerItem from './saveContainerItem'
import saveContainer from './saveContainer'
import removeCollectionObject from './removeCollectionObject'
import newCollectionObject from './newCollectionObject'
import newTaxonDetermination from './newTaxonDetermination'
import newCollectionEvent from './newCollectionEvent'
import newTypeMaterial from './newTypeMaterial'
import newIdentifier from './newIdentifier'
import newLabel from './newLabel'
import saveLabel from './saveLabel'
import removeDepictionsByImageId from './removeDepictionsByImageId'
import removeTaxonDetermination from './removeTaxonDetermination'
import resetWithDefault from './resetWithDefault'
import addToContainer from './AddToContainer'
import removeTypeMaterial from './removeTypeMaterial'

const ActionFunctions = {
  [ActionNames.AddToContainer]: addToContainer,
  [ActionNames.LoadDigitalization]: loadDigitalization,
  [ActionNames.LoadContainer]: loadContainer,
  [ActionNames.GetTaxon]: getTaxon,
  [ActionNames.GetLabels]: getLabels,
  [ActionNames.GetNamespace]: getNamespace,
  [ActionNames.GetIdentifier]: getIdentifier,
  [ActionNames.GetIdentifiers]: getIdentifiers,
  [ActionNames.GetTypeMaterial]: getTypeMaterial,
  [ActionNames.GetCollectionObject]: getCollectionObject,
  [ActionNames.GetCollectionEvent]: getCollectionEvent,
  [ActionNames.GetTaxonDeterminations]: getTaxonDeterminations,
  [ActionNames.SaveDigitalization]: saveDigitalization,
  [ActionNames.SaveIdentifier]: saveIdentifier,
  [ActionNames.SaveCollectionObject]: saveCollectionObject,
  [ActionNames.SaveCollectionEvent]: saveCollectionEvent,
  [ActionNames.SaveTypeMaterial]: saveTypeMaterial,
  [ActionNames.SaveDetermination]: saveDetermination,
  [ActionNames.SaveDeterminations]: saveDeterminations,
  [ActionNames.SaveContainerItem]: saveContainerItem,
  [ActionNames.SaveContainer]: saveContainer,
  [ActionNames.RemoveCollectionObject]: removeCollectionObject,
  [ActionNames.NewCollectionObject]: newCollectionObject,
  [ActionNames.NewIdentifier]: newIdentifier,
  [ActionNames.NewTaxonDetermination]: newTaxonDetermination,
  [ActionNames.NewCollectionEvent]: newCollectionEvent,
  [ActionNames.NewTypeMaterial]: newTypeMaterial,
  [ActionNames.NewLabel]: newLabel,
  [ActionNames.SaveLabel]: saveLabel,
  [ActionNames.RemoveDepictionsByImageId]: removeDepictionsByImageId,
  [ActionNames.RemoveTaxonDetermination]: removeTaxonDetermination,
  [ActionNames.ResetWithDefault]: resetWithDefault,
  [ActionNames.RemoveTypeMaterial]: removeTypeMaterial
}

export { ActionNames, ActionFunctions }
