import { MutationNames } from '../mutations/mutations'
import { Depiction } from 'routes/endpoints'

export default ({ commit, state: { depictions } }, depiction) =>
  new Promise((resolve, reject) => {
    const deleteDepictions = depictions.filter(item => item.image_id === depiction.image_id && item.id !== depiction.id)
    const promises = []

    deleteDepictions.forEach(item => {
      promises.push(Depiction.destroy(item.id))
    })

    Promise.all(promises).then(() => {
      commit(MutationNames.SetDepictions, depictions.filter(item => item.image_id !== depiction.image_id))
      resolve(true)
    })
  })
