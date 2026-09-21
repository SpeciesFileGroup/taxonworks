import { AssertedEnvironment } from '@/routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import { sortArray } from '@/helpers'
import { OTU } from '@/constants'

export default ({ commit }, otuIds) =>
  new Promise((resolve, reject) => {
    AssertedEnvironment.where({
      asserted_environment_object_id: otuIds,
      asserted_environment_object_type: OTU
    }).then(
      (response) => {
        commit(
          MutationNames.SetAssertedEnvironments,
          sortArray(response.body, 'position')
        )
        resolve(response)
      },
      (error) => {
        reject(error)
      }
    )
  })
