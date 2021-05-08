import baseCRUD from './base'

const permitParams = {
  taxon_determination: {
    biological_collection_object_id: Number,
    otu_id: Number,
    year_made: Number,
    month_made: Number,
    day_made: Number,
    position: Number,
    roles_attributes: {
      id: Number,
      _destroy: Boolean,
      type: String,
      person_id: Number,
      position: Number,
      person_attributes: {
        last_name: String,
        first_name: String,
        suffix: String,
        prefix: String
      }
    },
    otu_attributes: {
      id: Number,
      _destroy: Boolean,
      name: String,
      taxon_name_id: Number
    }
  }
}

export const TaxonDetermination = {
  ...baseCRUD('taxon_determinations', permitParams)
}
