import baseCRUD from './base'

const permitParams = {
  biological_association: {
    biological_relationship_id: Number,
    biological_association_subject_id: Number,
    biological_association_subject_type: String,
    biological_association_object_id: Number,
    biological_association_object_type: String,
    subject_global_id: Number,
    object_global_id: Number,
    origin_citation_attributes: {
      id: Number,
      _destroy: Boolean,
      source_id: Number,
      pages: String
    },
    citations_attributes: {
      id: Number,
      is_original: Boolean,
      _destroy: Boolean,
      source_id: Number,
      pages: String,
      citation_object_id: Number,
      citation_object_type: String
    }
  }
}

export const BiologicalAssociation = {
  ...baseCRUD('biological_associations', permitParams)
}
