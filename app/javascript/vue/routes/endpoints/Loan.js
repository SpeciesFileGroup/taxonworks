import baseCRUD from './base'
import AjaxCall from 'helpers/ajaxCall.js'

const controller = 'loans'
const permitParams = {
  loan: {
    date_requested: String,
    request_method: String,
    date_sent: String,
    date_received: String,
    date_return_expected: String,
    recipient_person_id: Number,
    recipient_address: String,
    recipient_email: String,
    recipient_phone: String,
    recipient_country: String,
    supervisor_person_id: Number,
    supervisor_email: String,
    supervisor_phone: String,
    date_closed: String,
    recipient_honorific: String,
    lender_address: String,
    clone_from: String,
    is_gift: Boolean,
    loan_items_attributes: {
      _destroy: Boolean,
      id: Number,
      global_entity: String,
      loan_item_object_type: String,
      loan_item_object_id: Number,
      position: Number,
      total: Number,
      disposition: String,
      date_: String,
      date_returned_jquery: String
    },
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
    }
  }
}

export const Loan = {
  ...baseCRUD(controller, permitParams),

  filter: params => AjaxCall('post', `/${controller}/filter.json`, params),

  attributes: () => AjaxCall('get', `/${controller}/attributes`)
}
