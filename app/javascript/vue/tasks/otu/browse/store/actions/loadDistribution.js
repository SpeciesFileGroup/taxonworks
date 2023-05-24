import { Otu } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import { TAXON_RANK_SPECIES_GROUP } from 'constants/index.js'

export default async ({ state, commit }, otuId) => {
  const taxonRank = state.taxonName?.rank_string
  const isSpeciesGroup =
    taxonRank && isRankGrpup(TAXON_RANK_SPECIES_GROUP, taxonRank)
  const { body } = isSpeciesGroup
    ? await Otu.geoJsonDistribution(otuId)
    : await Otu.distribution(otuId)

  if (isSpeciesGroup) {
    commit(MutationNames.SetGeoreferences, body)
  } else {
    commit(MutationNames.SetGeoreferences, {
      features: [JSON.parse(body.geo_json)]
    })
  }

  state.loadState.distribution = false
}

function isRankGrpup(compareRank, rank) {
  const rankGroup = rank.split('::').at(2)

  return rankGroup === compareRank
}
