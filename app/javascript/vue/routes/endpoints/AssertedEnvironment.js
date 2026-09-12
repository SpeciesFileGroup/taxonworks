import baseCRUD from './base'

const controller = 'asserted_environments'
const permitParams = {
  asserted_environment: {
    id: Number,
    asserted_environment_object_id: Number,
    asserted_environment_object_type: String,
    uri: String,
    uri_label: String,
    position: Number
  }
}

export const AssertedEnvironment = {
  ...baseCRUD(controller, permitParams)
}
