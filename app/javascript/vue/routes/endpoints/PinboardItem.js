import baseCRUD from './base'

const permitParams = {
  pinboard_item: {
    pinned_object_id: Number,
    pinned_object_type: String,
    user_id: Number,
    is_inserted: Boolean,
    is_cross_project: Boolean,
    inserted_count: Number
  }
}

export const PinboardItem = {
  ...baseCRUD('pinboard_items', permitParams)
}
