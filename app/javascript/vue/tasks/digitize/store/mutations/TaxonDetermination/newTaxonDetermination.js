import taxonDetermination from '../../../const/taxonDetermination'

export default (state, value) => {
  const newDetermination = taxonDetermination()
  newDetermination.otu_id = state.settings.locked.taxon_determination.otu_id ? state.taxon_determination.otu_id : undefined
  newDetermination.roles_attributes = state.settings.locked.taxon_determination.roles_attributes ? state.taxon_determination.roles_attributes : []
  if (state.settings.locked.taxon_determination.dates) {
    newDetermination.year_made = state.taxon_determination.year_made
    newDetermination.month_made = state.taxon_determination.month_made
    newDetermination.day_made = state.taxon_determination.day_made
  }
  state.taxon_determination = newDetermination
}
