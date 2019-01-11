import { MutationNames } from '../mutations/mutations'
import newCollectionEvent from '../../const/collectingEvent'

export default function ({ commit }) {
  commit(MutationNames.SetCollectionEvent, newCollectionEvent())
}