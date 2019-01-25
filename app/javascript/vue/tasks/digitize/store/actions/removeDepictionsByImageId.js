import { MutationNames } from '../mutations/mutations'
import { DestroyDepiction } from '../../request/resources'

export default function ({ commit, state }, depiction) {
  return new Promise((resolve, reject) => {
    let deleteDepictions = state.depictions.filter(item => {
      return item.image_id == depiction.image_id && item.id != depiction.id
    })
    let promises = []

    deleteDepictions.forEach(item => {
      promises.push(DestroyDepiction(item.id))
    })

    Promise.all(promises).then(() => {
      commit(MutationNames.SetDepictions, state.depictions.filter(item => {
        return item.image_id != depiction.image_id
      }))
      resolve(true);
    })
  })
}