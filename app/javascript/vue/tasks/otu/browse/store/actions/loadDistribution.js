import { Otu, CachedMap } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import { TAXON_RANK_SPECIES_GROUP } from 'constants/index.js'

export default async ({ state, commit }, otuId) => {
  const taxonRank = state.taxonName?.rank_string
  const isSpeciesGroup =
    taxonRank && isRankGrpup(TAXON_RANK_SPECIES_GROUP, taxonRank)

  state.loadState.distribution = true

  function loadDistribution() {
    Otu.distribution(otuId)
      .then(({ body }) => {
        const geojson = JSON.parse(body.cached_map.geo_json)

        geojson.properties = { aggregate: true }
        commit(MutationNames.SetGeoreferences, { features: [geojson] })

        CachedMap.find(body.cached_map.id).then((response) => {
          state.cachedMap = response.body
        })
      })
      .finally((_) => {
        state.loadState.distribution = false
      })
  }

  if (isSpeciesGroup) {
    Otu.geoJsonDistribution(otuId)
      .then((response) => {
        commit(MutationNames.SetGeoreferences, response.body)
        state.loadState.distribution = false
      })
      .catch(() => loadDistribution())
  } else {
    loadDistribution()
  }
}

function isRankGrpup(compareRank, rank) {
  const rankGroup = rank.split('::').at(2)

  return rankGroup === compareRank
}
