import { AssertedDistribution } from '@/routes/endpoints'
import { MutationNames } from '../mutations/mutations'

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
        const assertedDistributions = response.body.sort((a, b) => {
          const compareA = a.asserted_distribution_shape.name
          const compareB = b.asserted_distribution_shape.name
          if (compareA < compareB) {
            return -1
          } else if (compareA > compareB) {
            return 1
          } else {
            return 0
          }
        })

        commit(MutationNames.SetAssertedDistributions, assertedDistributions)
        resolve(response)
      },
      (error) => {
        reject(error)
      }
    )
  })
