import ActionNames from './actionNames'
import getTaxon from './getTaxon'
import saveDigitalization from './saveDigitalization'
import saveIdentifier from './saveIdentifier'
import saveCollectionObject from './saveCollectionObject'

const ActionFunctions = {
  [ActionNames.GetTaxon]: getTaxon,
  [ActionNames.SaveDigitalization]: saveDigitalization,
  [ActionNames.SaveIdentifier]: saveIdentifier,
  [ActionNames.SaveCollectionObject]: saveCollectionObject
}

export { ActionNames, ActionFunctions }
