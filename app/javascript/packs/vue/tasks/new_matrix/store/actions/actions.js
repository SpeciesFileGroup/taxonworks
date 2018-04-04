import ActionNames from './actionNames'
import createRowItem from './createRowItem'
import getMatrixObservationRows from './loadRowItems'
import getMatrixObservationColumns from './loadColumnItems'
import loadMatrix from './loadMatrix'

const ActionFunctions = {
  [ActionNames.CreateRowItem]: createRowItem,
  [ActionNames.LoadMatrix]: loadMatrix,
  [ActionNames.GetMatrixObservationRows]: getMatrixObservationRows,
  [ActionNames.GetMatrixObservationColumns]: getMatrixObservationColumns
}

export { ActionNames, ActionFunctions }