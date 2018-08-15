import { GetCollectionObject } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }, id) {
  GetCollectionObject(id).then(response => {
    commit(MutationNames.SetCollectionObject, response)
  })
}