import baseCRUD from './base'
import AjaxCall from 'helpers/ajaxCall'

const permitParams = {
  taxon_name_relationship: {
    id: Number,
    subject_taxon_name_id: Number,
    object_taxon_name_id: Number,
    type: String,
    origin_citation_attributes: {
      id: Number,
      _destroy: Boolean,
      source_id: Number,
      pages: String
    }
  }
}

export const TaxonNameRelationship = {
  ...baseCRUD('taxon_name_relationships', permitParams),
  types: () => AjaxCall('get', '/taxon_name_relationships/taxon_name_relationship_types')
}
