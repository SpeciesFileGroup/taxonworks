import { Otu, CachedMap } from '@/routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import { GetterNames } from '../getters/getters'
import { LEGEND } from '../../const/legend'
import {
  removeDuplicateShapes,
  setPopupAndIconToFeatures,
  addAggregateDataToFeature
} from '../../utils'

function sortFeaturesByType(arr, reference) {
  const referenceMap = new Map()

  reference.forEach((item, index) => {
    referenceMap.set(item, index)
  })

  return arr.toSorted((a, b) => {
    const indexA = referenceMap.has(a.properties.base.type)
      ? referenceMap.get(a.properties.base.type)
      : Infinity
    const indexB = referenceMap.has(b.properties.base.type)
      ? referenceMap.get(b.properties.base.type)
      : Infinity
    return indexA - indexB
  })
}

export default async ({ state, commit, getters }, otuId) => {
  const isSpeciesGroup = getters[GetterNames.IsSpeciesGroup]

  state.loadState.distribution = true

  function loadDistribution() {
    Otu.distribution(otuId)
      .then((response) => {
        if (response.status === 404) return
        const geojson = JSON.parse(response.body.cached_map.geo_json)
        const feature = addAggregateDataToFeature(geojson)

        commit(MutationNames.SetGeoreferences, {
          features: setPopupAndIconToFeatures([feature])
        })

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
      .then(({ body }) => {
        const { features, shapeTypes } = removeDuplicateShapes(
          sortFeaturesByType(body.features, Object.keys(LEGEND))
        )

        commit(MutationNames.SetGeoreferences, {
          features: setPopupAndIconToFeatures(features)
        })
        state.shapeTypes = shapeTypes
        state.loadState.distribution = false
      })
      .catch(() => {
        loadDistribution()
      })
  } else {
    loadDistribution()
  }
}
