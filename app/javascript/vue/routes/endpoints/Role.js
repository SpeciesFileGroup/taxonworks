import baseCRUD from './base'

const permitParams = {
  role: {
    position: Number,
    type: String,
    person_id: Number,
    role_object_id: Number,
    role_object_type: String,
    organization_id: Number,
    annotated_global_entity: String
  }
}

export const Role = {
  ...baseCRUD('roles', permitParams)
}
