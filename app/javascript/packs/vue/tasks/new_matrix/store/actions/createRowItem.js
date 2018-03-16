import { MutationNames } from '../mutations/mutations'
import { CreateRowItem } from '../../request/resources'

export default function ({ commit, state }, data) {
  return new Promise((resolve, rejected) => {
    console.log(data)
    CreateRowItem({ observation_matrix_row_item: data }).then(response => {
      TW.workbench.alert.create('Row item was successfully created.', 'notice')
      return resolve(response)
    })
  }, (response) => {
    return rejected(response)
  })
};
