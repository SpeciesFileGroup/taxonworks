import ActionNames from './actionNames'
import createRowItem from './createRowItem'
import getMatrixObservationRows from './loadRowItems'
import getMatrixObservationColumns from './loadColumnItems'
import loadMatrix from './loadMatrix'
import removeRow from './removeRow'
import removeColumn from './removeColumn'

const ActionFunctions = {
  [ActionNames.CreateRowItem]: createRowItem,
  [ActionNames.LoadMatrix]: loadMatrix,
  [ActionNames.GetMatrixObservationRows]: getMatrixObservationRows,
  [ActionNames.GetMatrixObservationColumns]: getMatrixObservationColumns,
  [ActionNames.RemoveRow]: removeRow,
  [ActionNames.RemoveColumn]: removeColumn
}

export { ActionNames, ActionFunctions }