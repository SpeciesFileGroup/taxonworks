import baseCRUD from './base'

const permitParams = {
  loan_item: {
    loan_id: Number,
    collection_object_status: String,
    date_returned: String,
    loan_item_object_id: Number,
    loan_item_object_type: String,
    date_returned_jquery: String,
    disposition: Number,
    total: Number,
    global_entity: String,
    position: Number
  }
}

export const LoanItem = {
  ...baseCRUD('loan_items', permitParams)
}
