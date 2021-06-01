import { MutationNames } from '../mutations/mutations'
import { TaxonDetermination } from 'routes/endpoints'

export default ({ commit, state: { taxon_determinations } }, determination) =>
  new Promise((resolve, reject) => {
    if (determination.id) {
      TaxonDetermination.destroy(determination.id).then(() => {
        commit(MutationNames.RemoveTaxonDetermination, determination.id)
      })
    } else {
      taxon_determinations.splice(
        taxon_determinations.findIndex(det => det.otu_id === determination.otu_id), 1)
    }
  })
