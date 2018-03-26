import { MutationNames } from '../mutations/mutations'
import { GetMatrixObservation, GetMatrixObservationRows, GetMatrixObservationColumns } from '../../request/resources'

export default function ({ commit, state }, id) {
  return new Promise((resolve, rejected) => {
    GetMatrixObservation(id).then(response => {
      commit(MutationNames.SetMatrix, response)
      GetMatrixObservationRows(id).then(rows => {
        commit(MutationNames.SetMatrixRows, rows)
      });
      GetMatrixObservationColumns(id).then(columns => {
        commit(MutationNames.SetMatrixColumns, columns)
      });
      return resolve(response)
    }, (response) => {
      return rejected(response)
    })
  })
};