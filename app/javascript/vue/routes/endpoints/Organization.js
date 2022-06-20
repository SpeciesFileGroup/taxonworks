import baseCRUD from './base'

const permitParams = {
  organization: {
    name: String,
    alternate_name: String,
    description: String,
    disambiguating_description: String,
    same_as_id: Number,
    address: String,
    email: String,
    telephone: String,
    duns: String,
    global_location_number: String,
    legal_name: String,
    area_served_id: Number, 
    department_id: Number,
    parent_organization_id: Number
  }
}

export const Organization = {
  ...baseCRUD('organizations', permitParams)
}
