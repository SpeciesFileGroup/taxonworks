import { MutationNames } from '../mutations/mutations'
import { CreateTaxonDetermination, UpdateTaxonDetermination } from '../../request/resources'
import ValidateDetermination from '../../validations/determination'
import TaxonDetermination from '../../const/taxonDetermination'

export default function ({ commit, state }, determination) {
  return new Promise((resolve, reject) => {
    let taxon_determination = determination
    taxon_determination.biological_collection_object_id = state.collection_object.id

    if(ValidateDetermination(taxon_determination)) {
      if(taxon_determination.id) {
        UpdateTaxonDetermination(taxon_determination).then(response => {
          state.collection_object.object_tag = response.body.collection_object.object_tag
          commit(MutationNames.AddTaxonDetermination, response.body)
          resolve(response.body)
        }, (response) => {
          reject(response)
        })
      }
      else {
        CreateTaxonDetermination(taxon_determination).then(response => {
          state.collection_object.object_tag = response.body.collection_object.object_tag
          commit(MutationNames.AddTaxonDetermination, response.body)
          resolve(response.body)
        }, (response) => {
          reject(response)
        })
      }
    }
    else {
      resolve()
    }
  })
}