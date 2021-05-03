import baseCRUD from './base'
import AjaxCall from 'helpers/ajaxCall'

const permitParams = {
  taxon_name_classification: {
    id: Number,
    taxon_name_id: Number,
    type: String,
    origin_citation_attributes: {
      id: Number,
      _destroy: Boolean,
      source_id: Number,
      pages: String
    }
  }
}

export const TaxonNameClassification = {
  ...baseCRUD('taxon_name_classifications', permitParams),
  types: () => AjaxCall('get', '/taxon_name_classifications/taxon_name_classification_types')
}
