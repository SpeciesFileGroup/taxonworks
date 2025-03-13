import { FieldOccurrence } from '@/routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }, otuId) =>
  new Promise((resolve, reject) => {
    FieldOccurrence.all({
      otu_id: otuId,
      current_determinations: true,
      extend: ['dwc_occurrence']
    }).then(
      (response) => {
        state.loadState.fieldOccurrences = false
        commit(
          MutationNames.SetFieldOccurrences,
          state.fieldOccurrences.concat(response.body)
        )
        resolve(response)
      },
      (error) => {
        reject(error)
      }
    )
  })
