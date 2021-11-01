import { SoftValidation } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }, globalId) =>
  SoftValidation.find(globalId).then(({ body }) => {
    commit(MutationNames.SetSoftValidation, {
      sources: {
        list: body.soft_validations.length
          ? [body]
          : [],
        title: 'Source'
      }
    })
  })
