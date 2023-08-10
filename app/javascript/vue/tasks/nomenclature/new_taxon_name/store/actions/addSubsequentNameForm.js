import ActionNames from './actionNames'
import { TaxonName } from '@/routes/endpoints'
import { TAXON_RELATIONSHIP_FAMILY_GROUP_NAME_FORM } from '@/constants'

export default async ({ state, dispatch }, { name, citation }) => {
  const currentTaxon = state.taxon_name
  const payload = {
    name,
    parent_id: currentTaxon.parent_id,
    rank_class: currentTaxon.rank_string,
    type: 'Protonym'
  }

  if (citation.source_id) {
    Object.assign(payload, {
      origin_citation_attributes: { ...citation, is_original: true }
    })
  }

  return TaxonName.create({
    taxon_name: payload
  }).then(({ body }) =>
    dispatch(ActionNames.AddTaxonRelationship, {
      type: TAXON_RELATIONSHIP_FAMILY_GROUP_NAME_FORM,
      object_taxon_name_id: currentTaxon.id,
      subject_taxon_name_id: body.id
    })
  )
}
