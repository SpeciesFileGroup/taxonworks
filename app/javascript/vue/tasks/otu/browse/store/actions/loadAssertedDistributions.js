import { AssertedDistribution } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import nonReactiveStore from '../nonReactiveStore.js'

const embed = [
  'shape',
  'lavel_names'
]
const extend = [
  'citations',
  'geographic_area',
  'geographic_area_type',
  'origin_citation',
  'shape',
  'source',
  'otu'
]

export default ({ commit }, otusId) => new Promise((resolve, reject) => {
  AssertedDistribution.where({ otu_id: otusId, embed, extend }).then(response => {
    const shapes = response.body.map(item => item.geographic_area.shape)

    nonReactiveStore.geographicAreas = [...new Map(shapes.map(item => [item.properties.geographic_area.id, item])).values()]

    const assertedDistributions = response.body.map(ad => {
      ad.geographic_area.shape = !!ad.geographic_area.shape

      return ad
    }).sort((a, b) => {
      const compareA = a.geographic_area.name
      const compareB = b.geographic_area.name
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
  }, error => {
    reject(error)
  })
})
