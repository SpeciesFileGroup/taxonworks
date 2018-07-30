import ActionNames from './actionNames'
import getTaxon from './getTaxon'
import saveDigitalization from './saveDigitalization'
import saveIdentifier from './saveIdentifier'
import saveCollectionObject from './saveCollectionObject'
import saveCollectionEvent from './saveCollectionEvent'
import saveTypeMaterial from './saveTypeMaterial'

const ActionFunctions = {
  [ActionNames.GetTaxon]: getTaxon,
  [ActionNames.SaveDigitalization]: saveDigitalization,
  [ActionNames.SaveIdentifier]: saveIdentifier,
  [ActionNames.SaveCollectionObject]: saveCollectionObject,
  [ActionNames.SaveCollectionEvent]: saveCollectionEvent,
  [ActionNames.SaveTypeMaterial]: saveTypeMaterial
}

export { ActionNames, ActionFunctions }
