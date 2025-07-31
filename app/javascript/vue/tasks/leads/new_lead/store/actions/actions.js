import addLead from './addLead.js'
import dataChangedSinceLastSave from './dataChangedSinceLastSave.js'
import { childrenChangedSinceLastSaveList, originLabelChangedSinceLastSave }
  from './dataChangedSinceLastSave.js'
import deleteChild from './deleteChild'
import loadKey from './loadKey.js'
import resetChildren from './resetChildren.js'
import updateChild from './updateChild.js'

const ActionNames = {
  AddLead: 'addLead',
  ChildrenChangedSinceLastSaveList: 'childrenChangedSinceLastSaveList',
  DataChangedSinceLastSave: 'dataChangedSinceLastSave',
  DeleteChild: 'deleteChild',
  LoadKey: 'loadKey',
  OriginLabelChangedSinceLastSave: 'originLabelChangedSinceLastSave',
  ResetChildren: 'resetChildren',
  UpdateChild: 'updateChild'
}

const ActionFunctions = {
  [ActionNames.AddLead]: addLead,
  [ActionNames.DataChangedSinceLastSave]: dataChangedSinceLastSave,
  [ActionNames.DeleteChild]: deleteChild,
  [ActionNames.ChildrenChangedSinceLastSaveList]: childrenChangedSinceLastSaveList,
  [ActionNames.LoadKey]: loadKey,
  [ActionNames.OriginLabelChangedSinceLastSave]: originLabelChangedSinceLastSave,
  [ActionNames.ResetChildren]: resetChildren,
  [ActionNames.UpdateChild]: updateChild
}

export {
  ActionNames,
  ActionFunctions
}