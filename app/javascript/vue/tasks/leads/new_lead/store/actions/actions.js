import dataChangedSinceLastSave from './dataChangedSinceLastSave.js'
import { childrenChangedSinceLastSaveList, originLabelChangedSinceLastSave }
  from './dataChangedSinceLastSave.js'
import loadKey from './loadKey.js'
import updateChild from './updateChild.js'

const ActionNames = {
  DataChangedSinceLastSave: 'dataChangedSinceLastSave',
  childrenChangedSinceLastSaveList: 'childrenChangedSinceLastSaveList',
  LoadKey: 'loadKey',
  OriginLabelChangedSinceLastSave: 'originLabelChangedSinceLastSave',
  UpdateChild: 'updateChild'
}

const ActionFunctions = {
  [ActionNames.DataChangedSinceLastSave]: dataChangedSinceLastSave,
  [ActionNames.childrenChangedSinceLastSaveList]: childrenChangedSinceLastSaveList,
  [ActionNames.LoadKey]: loadKey,
  [ActionNames.OriginLabelChangedSinceLastSave]: originLabelChangedSinceLastSave,
  [ActionNames.UpdateChild]: updateChild
}

export {
  ActionNames,
  ActionFunctions
}