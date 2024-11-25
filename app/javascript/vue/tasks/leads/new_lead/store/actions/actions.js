import addLead from './addLead.js'
import dataChangedSinceLastSave from './dataChangedSinceLastSave.js'
import { childrenChangedSinceLastSaveList, originLabelChangedSinceLastSave }
  from './dataChangedSinceLastSave.js'
import loadKey from './loadKey.js'
import updateChild from './updateChild.js'

const ActionNames = {
  AddLead: 'addLead',
  ChildrenChangedSinceLastSaveList: 'childrenChangedSinceLastSaveList',
  DataChangedSinceLastSave: 'dataChangedSinceLastSave',
  LoadKey: 'loadKey',
  OriginLabelChangedSinceLastSave: 'originLabelChangedSinceLastSave',
  UpdateChild: 'updateChild'
}

const ActionFunctions = {
  [ActionNames.AddLead]: addLead,
  [ActionNames.DataChangedSinceLastSave]: dataChangedSinceLastSave,
  [ActionNames.ChildrenChangedSinceLastSaveList]: childrenChangedSinceLastSaveList,
  [ActionNames.LoadKey]: loadKey,
  [ActionNames.OriginLabelChangedSinceLastSave]: originLabelChangedSinceLastSave,
  [ActionNames.UpdateChild]: updateChild
}

export {
  ActionNames,
  ActionFunctions
}