import foundRankGroup from '../../helpers/foundRankGroup'
import truncateAtRank from '../../helpers/truncateAtRank'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }, parent) {
  let nomenclatureRanks = JSON.parse(JSON.stringify(state.ranks[state.nomenclatural_code]))
  let group = foundRankGroup(nomenclatureRanks, parent.rank)
  if (group) {
    nomenclatureRanks[group] = truncateAtRank(nomenclatureRanks[group], parent.rank)
  }
  commit(MutationNames.SetParentRankGroup, group)
  commit(MutationNames.SetAllRanks, nomenclatureRanks)
  commit(MutationNames.SetParent, parent)
}
