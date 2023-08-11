import { MutationNames } from '../mutations/mutations'
import { TaxonName, TaxonNameRelationship } from '@/routes/endpoints'
import { TAXON_RELATIONSHIP_FAMILY_GROUP_NAME_FORM } from '@/constants'

export default async ({ state, commit }, { name, citation }) => {
  const currentTaxon = state.taxon_name
  const payload = {
    name,
    parent_id: currentTaxon.parent_id,
    rank_class: currentTaxon.rank_string,
    type: 'Protonym',
    family_group_name_form_relationship_attributes: {
      object_taxon_name_id: currentTaxon.id
    }
  }

  if (citation.source_id) {
    Object.assign(payload, {
      origin_citation_attributes: { ...citation, is_original: true }
    })
  }

  return TaxonName.create({
    taxon_name: payload
  }).then(({ body }) =>
    TaxonNameRelationship.where({
      type: TAXON_RELATIONSHIP_FAMILY_GROUP_NAME_FORM,
      object_taxon_name_id: currentTaxon.id,
      subject_taxon_name_id: body.id
    }).then(({ body }) => {
      body.forEach((item) => {
        commit(MutationNames.AddTaxonRelationship, item)
      })
    })
  )
}
