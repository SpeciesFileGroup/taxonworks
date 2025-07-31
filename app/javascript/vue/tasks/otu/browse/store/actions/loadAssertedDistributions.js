import { AssertedDistribution } from '@/routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import { sortArray } from '@/helpers'

import listParser from '@/tasks/otu/browse_asserted_distributions/helpers/listParser.js'

const embed = ['level_names']
const extend = [
  'citations',
  'asserted_distribution_shape',
  'shape_type',
  'origin_citation',
  'source',
  'otu'
]

export default ({ commit }, otusId) =>
  new Promise((resolve, reject) => {
    AssertedDistribution.all({ otu_id: otusId, embed, extend }).then(
      (response) => {
        const list = listParser(response.body)
        commit(
          MutationNames.SetAssertedDistributions,
          sortArray(list, 'asserted_distribution_shape.name')
        )
        resolve(response)
      },
      (error) => {
        reject(error)
      }
    )
  })
