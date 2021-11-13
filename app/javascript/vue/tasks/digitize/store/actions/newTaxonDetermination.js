import makeTaxonDetermination from 'factory/TaxonDetermination'
import { MutationNames } from '../mutations/mutations'

export default ({ commit, state }) => {
  const newTD = makeTaxonDetermination()
  const locked = state.settings.locked.taxon_determination
  const keys = Object.keys(locked)

  keys.forEach(key => {
    newTD[key] = locked[key] ? state.taxon_determination[key] : undefined
  })

  if(locked.dates) {
    newTD.year_made = state.taxon_determination.year_made
    newTD.month_made = state.taxon_determination.month_made
    newTD.day_made = state.taxon_determination.day_made
  }

  if(!newTD.roles_attributes) {
    newTD.roles_attributes = []
  }

  commit(MutationNames.SetTaxonDetermination, newTD)
}