import ActionNames from './actionNames'
import { TaxonName, Citation } from '@/routes/endpoints'
import {
  TAXON_RELATIONSHIP_FAMILY_GROUP_NAME_FORM,
  TAXON_NAME_RELATIONSHIP
} from '@/constants'

export default async ({ state, dispatch }, { name, citation }) => {
  const currentTaxon = state.taxon_name
  const payload = {
    name,
    parent_id: currentTaxon.parent_id,
    rank_class: currentTaxon.rank_string,
    type: 'Protonym'
  }

  try {
    const response = await TaxonName.create({
      taxon_name: payload
    })

    const taxonRelationship = dispatch(ActionNames.AddTaxonRelationship, {
      type: TAXON_RELATIONSHIP_FAMILY_GROUP_NAME_FORM,
      object_taxon_name_id: currentTaxon.id,
      subject_taxon_name_id: response.body.id
    })

    taxonRelationship.then((relationship) => {
      if (citation.source_id) {
        createCitation(relationship.id)
      }
    })

    return taxonRelationship
  } catch {}

  function createCitation(id) {
    const payload = {
      ...citation,
      citation_object_id: id,
      citation_object_type: TAXON_NAME_RELATIONSHIP
    }

    Citation.create({ citation: payload }).catch((e) => {})
  }
}
