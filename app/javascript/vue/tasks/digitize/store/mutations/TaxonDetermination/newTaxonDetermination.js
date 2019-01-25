import taxonDetermination from '../../../const/taxonDetermination'

export default function(state, value) {
  state.taxon_determination = taxonDetermination()
}