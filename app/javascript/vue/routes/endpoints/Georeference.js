import baseCRUD from './base'

const permitParams = {
  georeference: {
    iframe_response: String,
    submit: String,
    geographic_item_id: Number,
    collecting_event_id: Number,
    error_radius: Number,
    error_depth: Number,
    error_geographic_item_id: Number,
    type: String,
    position: Number,
    is_public: Boolean,
    api_request: String,
    is_undefined_z: Boolean,
    is_median_z: Boolean,
    wkt: Number,
    year_georeferenced: Number,
    day_georeferenced: Number,
    month_georeferenced: Number,
    geographic_item_attributes: {
      shape: Object
    },
    origin_citation_attributes: {
      id: Number,
      _destroy: Boolean,
      source_id: Number,
      pages: Number
    }
  }
}

export const Georeference = {
  ...baseCRUD('georeferences', permitParams)
}
