import ActionNames from './actionNames'
import getTaxon from './getTaxon'
import saveDigitalization from './saveDigitalization'
import saveIdentifier from './saveIdentifier'
import saveCollectionObject from './saveCollectionObject'
import saveCollectionEvent from './saveCollectionEvent'
import saveTypeMaterial from './saveTypeMaterial'
import saveDetermination from './saveDetermination'
import saveContainerItem from './saveContainerItem'

const ActionFunctions = {
  [ActionNames.GetTaxon]: getTaxon,
  [ActionNames.SaveDigitalization]: saveDigitalization,
  [ActionNames.SaveIdentifier]: saveIdentifier,
  [ActionNames.SaveCollectionObject]: saveCollectionObject,
  [ActionNames.SaveCollectionEvent]: saveCollectionEvent,
  [ActionNames.SaveTypeMaterial]: saveTypeMaterial,
  [ActionNames.SaveDetermination]: saveDetermination,
  [ActionNames.SaveContainerItem]: saveContainerItem
}

export { ActionNames, ActionFunctions }
