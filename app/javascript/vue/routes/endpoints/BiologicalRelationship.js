import baseCRUD from './base'

const permitParams = {
  biological_relationship: {
    id: Number,
    name: String,
    definition: String,
    inverted_name: Number,
    is_transitive: Boolean,
    is_reflexive: Boolean,
    biological_relationship_types_attributes: {
      id: Number,
      _destroy: Boolean,
      type: String,
      biological_property_id: Number
    },
    origin_citation_attributes: {
      id: Number,
      _destroy: Boolean,
      source_id: Number,
      pages: String
    }
  }
}

export const BiologicalRelationship = {
  ...baseCRUD('biological_relationships', permitParams)
}
