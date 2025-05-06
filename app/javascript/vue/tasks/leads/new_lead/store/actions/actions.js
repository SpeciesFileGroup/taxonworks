import addLead from './addLead.js'
import dataChangedSinceLastSave from './dataChangedSinceLastSave.js'
import { childrenChangedSinceLastSaveList, originLabelChangedSinceLastSave }
  from './dataChangedSinceLastSave.js'
import addOtuIndex from './addOtuIndex.js'
import deleteChild from './deleteChild'
import loadKey from './loadKey.js'
import setLoading from './setLoading.js'
import resetChildren from './resetChildren.js'
import updateChild from './updateChild.js'

const ActionNames = {
  AddLead: 'addLead',
  AddOtuIndex: 'addOtuIndex',
  ChildrenChangedSinceLastSaveList: 'childrenChangedSinceLastSaveList',
  DataChangedSinceLastSave: 'dataChangedSinceLastSave',
  DeleteChild: 'deleteChild',
  LoadKey: 'loadKey',
  OriginLabelChangedSinceLastSave: 'originLabelChangedSinceLastSave',
  ResetChildren: 'resetChildren',
  SetLoading: 'setLoading',
  UpdateChild: 'updateChild'
}

const ActionFunctions = {
  [ActionNames.AddLead]: addLead,
  [ActionNames.AddOtuIndex]: addOtuIndex,
  [ActionNames.DataChangedSinceLastSave]: dataChangedSinceLastSave,
  [ActionNames.DeleteChild]: deleteChild,
  [ActionNames.ChildrenChangedSinceLastSaveList]: childrenChangedSinceLastSaveList,
  [ActionNames.LoadKey]: loadKey,
  [ActionNames.OriginLabelChangedSinceLastSave]: originLabelChangedSinceLastSave,
  [ActionNames.ResetChildren]: resetChildren,
  [ActionNames.SetLoading]: setLoading,
  [ActionNames.UpdateChild]: updateChild
}

export {
  ActionNames,
  ActionFunctions
}