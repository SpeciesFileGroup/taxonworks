import baseCRUD, { annotations } from './base'

const permitParams = {
  extract: {
    repository_id: Number,
    verbatim_anatomical_origin: String,
    year_made: Number,
    month_made: Number,
    day_made: Number,

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

    data_attributes_attributes: {
      id: Number,
      _destroy: Boolean,
      controlled_vocabulary_term_id: Number,
      type: String,
      attribute_subject_id: Number,
      attribute_subject_type: String,
      value: String
    }
  }
}

export const Extract = {
  ...baseCRUD('extracts', permitParams),
  ...annotations('extracts')
}
