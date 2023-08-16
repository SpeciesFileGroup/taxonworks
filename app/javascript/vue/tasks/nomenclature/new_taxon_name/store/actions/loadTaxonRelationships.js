import { TaxonNameRelationship } from '@/routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import {
  TAXON_RELATIONSHIP_CURRENT_COMBINATION,
  TAXON_RELATIONSHIP_FAMILY_GROUP_NAME_FORM
} from '@/constants/index.js'

export default ({ commit, state, dispatch }, id) =>
  new Promise((resolve, reject) => {
    const combinationRelationship = TaxonNameRelationship.where({
      object_taxon_name_id: id,
      taxon_name_relationship_type: [
        TAXON_RELATIONSHIP_CURRENT_COMBINATION,
        TAXON_RELATIONSHIP_FAMILY_GROUP_NAME_FORM
      ]
    })

    const taxonRelationships = TaxonNameRelationship.where({
      subject_taxon_name_id: id,
      taxon_name_relationship_set: ['synonym', 'status', 'classification']
    })

    Promise.all([combinationRelationship, taxonRelationships]).then(
      ([combResponse, taxonResponse]) => {
        const relationships = [...combResponse.body, ...taxonResponse.body]
        const typeRelationship = state.taxon_name.type_taxon_name_relationship

        if (typeRelationship) {
          relationships.push(state.taxon_name.type_taxon_name_relationship)
        }

        commit(MutationNames.SetTaxonRelationshipList, relationships)

        dispatch('loadSoftValidation', 'taxonRelationshipList')
        dispatch('loadSoftValidation', 'original_combination')
        return resolve()
      }
    )
  })
