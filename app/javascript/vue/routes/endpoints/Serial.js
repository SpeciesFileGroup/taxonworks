import baseCRUD from './base'

const permitParams = {
  serial: {
    name: String,
    publisher: String,
    place_published: String,
    primary_language_id: Number,
    first_year_of_issue: String,
    last_year_of_issue: String,
    translated_from_serial_id: Number,
    alternate_values_attributes: {
      id: Number,
      value: String,
      type: String,
      language_id: Number,
      alternate_value_object_type: String,
      alternate_value_object_id: Number,
      alternate_value_object_attribute: String,
      _destroy: Boolean
    }
  }
}

export const Serial = {
  ...baseCRUD('serials', permitParams)
}
