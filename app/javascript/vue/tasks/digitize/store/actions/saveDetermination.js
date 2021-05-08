import { MutationNames } from '../mutations/mutations'
import { TaxonDetermination } from 'routes/endpoints'
import ValidateDetermination from '../../validations/determination'

export default ({ commit, state }, determination) =>
  new Promise((resolve, reject) => {
    const taxon_determination = determination
    taxon_determination.biological_collection_object_id = state.collection_object.id

    if (ValidateDetermination(taxon_determination)) {
      const saveDetermination = taxon_determination.id
        ? TaxonDetermination.update(taxon_determination.id, { taxon_determination })
        : TaxonDetermination.create({ taxon_determination })

      saveDetermination.then(response => {
        state.collection_object.object_tag = response.body.collection_object.object_tag
        commit(MutationNames.AddTaxonDetermination, response.body)
        resolve(response.body)
      }, (response) => {
        reject(response)
      })
    } else {
      resolve()
    }
  })
