import { Otu } from '@/routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }, id) =>
  Otu.coordinate(id)
    .then(({ body }) => {
      commit(
        MutationNames.SetCurrentOtu,
        body.find((otu) => Number(otu.id) === Number(id))
      )
      commit(MutationNames.SetOtus, body)
    })
    .catch(() => {})
