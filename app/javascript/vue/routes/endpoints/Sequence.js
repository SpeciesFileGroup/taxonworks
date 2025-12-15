import baseCRUD from './base'
//import AjaxCall from '@/helpers/ajaxCall.js'

const controller = 'sequences'
const permitParams = {
  sequence: {
    sequence: String,
    sequence_type: String,
    name: String

  }
}

export const Sequence = {
  ...baseCRUD(controller, permitParams),
}
