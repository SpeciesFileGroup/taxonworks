import baseCRUD from './base'

const permitParams = {
  citation: {
    citation_object_type: String,
    citation_object_id: Number,
    source_id: Number,
    pages: String,
    is_original: Boolean,
    annotated_global_entity: String,
    citation_topics_attributes: {
      id: Number,
      _destroy: Boolean,
      pages: String,
      topic_id: Number,
      topic_attributes: {
        id: Number,
        _destroy: Boolean,
        name: String,
        definition: String
      }
    },
    topics_attributes: {
      name: String,
      definition: String
    }
  }
}

export const Citation = {
  ...baseCRUD('citations', permitParams)
}
