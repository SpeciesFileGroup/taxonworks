import baseCRUD, { annotations } from './base'

const permitParams = {
  person: {
    type: String,
    no_namecase: String,
    last_name: String,
    first_name: String,
    suffix: String,
    prefix: String,
    year_born: Number,
    year_died: Number,
    year_active_start: Number,
    year_active_end: Number
  }
}

export const People = {
  ...baseCRUD('people', permitParams),
  ...annotations('people')
}
