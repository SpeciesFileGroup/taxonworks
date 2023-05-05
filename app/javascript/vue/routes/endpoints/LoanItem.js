import baseCRUD from './base'
import AjaxCall from 'helpers/ajaxCall.js'

const controller = 'loan_items'
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
  ...baseCRUD(controller, permitParams),

  createBatch: (params) =>
    AjaxCall('post', `/${controller}/batch_create`, params),

  returnBatch: (params) =>
    AjaxCall('post', `/${controller}/batch_return`, params),

  moveBatch: (params) => AjaxCall('post', `/${controller}/batch_move`, params)
}
