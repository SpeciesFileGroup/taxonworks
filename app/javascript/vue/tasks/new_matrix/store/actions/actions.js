import ActionNames from './actionNames'
import createRowItem from './createRowItem'
import createColumnItem from './createColumnItem'
import getMatrixObservationRows from './loadRowItems'
import getMatrixObservationColumns from './loadColumnItems'
import getMatrixObservationRowsDynamic from './loadRowDynamicItems'
import getMatrixObservationColumnsDynamic from './loadColumnDynamicItems'
import loadMatrix from './loadMatrix'
import removeRow from './removeRow'
import removeColumn from './removeColumn'
import updateMatrix from './updateMatrix'

const ActionFunctions = {
  [ActionNames.CreateRowItem]: createRowItem,
  [ActionNames.CreateColumnItem]: createColumnItem,
  [ActionNames.LoadMatrix]: loadMatrix,
  [ActionNames.GetMatrixObservationRows]: getMatrixObservationRows,
  [ActionNames.GetMatrixObservationRowsDynamic]: getMatrixObservationRowsDynamic,
  [ActionNames.GetMatrixObservationColumns]: getMatrixObservationColumns,
  [ActionNames.GetMatrixObservationColumnsDynamic]: getMatrixObservationColumnsDynamic,
  [ActionNames.RemoveRow]: removeRow,
  [ActionNames.RemoveColumn]: removeColumn,
  [ActionNames.UpdateMatrix]: updateMatrix
}

export { ActionNames, ActionFunctions }