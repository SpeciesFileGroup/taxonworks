import { TAXON_RANK_SPECIES_GROUP } from '@/constants/index'

function isRankGrpup(compareRank, rank) {
  const rankGroup = rank.split('::').at(2)

  return rankGroup === compareRank
}

export default (state) => {
  const taxonName = state.taxonName?.rank_string

  return taxonName && isRankGrpup(TAXON_RANK_SPECIES_GROUP, taxonName)
}
