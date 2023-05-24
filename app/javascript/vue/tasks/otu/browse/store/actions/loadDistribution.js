import { Otu } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import { TAXON_RANK_SPECIES_GROUP } from 'constants/index.js'

export default async ({ state, commit }, otuId) => {
  const taxonRank = state.taxonName?.rank_string

  if (taxonRank && isRankGrpup(TAXON_RANK_SPECIES_GROUP, taxonRank)) {
    const { body } = Otu.distribution(otuId)
    commit(MutationNames.SetGeoreferences, body)
  } else {
    const { body } = await Otu.geoJsonDistribution(otuId)

    commit(MutationNames.SetGeoreferences, body)
  }
  state.loadState.distribution = false
}

function isRankGrpup(compareRank, rank) {
  const rankGroup = rank.split('::').at(2)

  return rankGroup === compareRank
}
