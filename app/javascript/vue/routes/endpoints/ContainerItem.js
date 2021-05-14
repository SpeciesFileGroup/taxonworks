import baseCRUD from './base'

const permitParams = {
  container_item: {
    global_entity: String,
    contained_object_id: Number,
    contained_object_type: String,
    container_id: Number,
    position: Number,
    parent_id: Number,
    disposition: String
  }
}

export const ContainerItem = {
  ...baseCRUD('container_items', permitParams)
}
