import { Otu, CachedMap } from '@/routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import { GetterNames } from '../getters/getters'

export default async ({ state, commit, getters }, otuId) => {
  const isSpeciesGroup = getters[GetterNames.IsSpeciesGroup]

  state.loadState.distribution = true

  function loadDistribution() {
    Otu.distribution(otuId)
      .then((response) => {
        if (response.status === 404) return
        const geojson = JSON.parse(response.body.cached_map.geo_json)

        geojson.properties = { aggregate: true }
        commit(MutationNames.SetGeoreferences, { features: [geojson] })

        CachedMap.find(response.body.cached_map.id).then((response) => {
          state.cachedMap = response.body
        })
      })
      .catch(() => {})
      .finally((_) => {
        state.loadState.distribution = false
      })
  }

  if (isSpeciesGroup) {
    Otu.geoJsonDistribution(otuId)
      .then((response) => {
        const features = response.body.features.map((item) => {
          item.properties.type = item.properties.shape.type

          return item
        })
        commit(MutationNames.SetGeoreferences, { features })
        state.loadState.distribution = false
      })
      .catch(() => {
        loadDistribution()
      })
  } else {
    loadDistribution()
  }
}
