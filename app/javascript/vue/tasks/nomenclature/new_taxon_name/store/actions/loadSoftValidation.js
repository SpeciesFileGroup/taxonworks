import { loadSoftValidation } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }, type) {
  let validations = []
  let promises = []

  if (Array.isArray(state[type])) {
    validations = state[type]
  } else {
    validations.push(state[type])
  }

  validations.forEach(function (element) {
    promises.push(
      loadSoftValidation(element.global_id).then(response => {
        return response
      })
    )
  })

  Promise.all(promises).then(response => {
    let validation = {
      response: (response[0] == undefined ? [] : response[0]),
      type: type
    }
    commit(MutationNames.SetSoftValidation, validation)
  })
}
