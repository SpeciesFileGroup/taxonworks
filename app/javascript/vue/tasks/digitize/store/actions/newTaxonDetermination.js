import newTaxonDetermination from '../../const/taxonDetermination'
import { MutationNames } from '../mutations/mutations'

export default function({ commit }) {
  commit(MutationNames.SetTaxonDetermination, newTaxonDetermination())
}