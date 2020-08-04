import { loadSoftValidation } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }, type) {
  let validations = []
  let promises = []

  if (Array.isArray(state[type])) {
    validations = state[type]
  } else if (state.softValidation[type].transform) {
    validations = state.softValidation[type].transform(state[type])
  } else {
    validations.push(state[type])
  }

  validations.forEach(function (element) {
    promises.push(
      loadSoftValidation(element.global_id).then(response => {
        return response.body
      })
    )
  })

  Promise.all(promises).then(response => {
    const validations = response.filter(item => item.validations.soft_validations.length)
    const data = {
      list: validations,
      type: type
    }
    commit(MutationNames.SetSoftValidation, data)
  })
}
