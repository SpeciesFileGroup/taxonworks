import baseCRUD from './base'

const permitParams = {
  common_name: {
    name: String,
    geographic_area_id: Number,
    otu_id: Number,
    language_id: Number,
    start_year: Number,
    end_year: Number
  }
}

export const CommonName = {
  ...baseCRUD('common_names', permitParams),
}
