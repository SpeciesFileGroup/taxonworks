import baseCRUD from './base'
import AjaxCall from 'helpers/ajaxCall'

const permitParams = {
  user: {
    name: String,
    email: String,
    password: String,
    password_confirmation: String,
    set_new_api_access_token: String,
    is_project_administrator: Boolean,
    is_flagged_for_password_reset: Boolean,
    is_administrator: Boolean,
    layout: Object
  }
}

export const User = {
  ...baseCRUD('users', permitParams),

  preferences: () => AjaxCall('get', '/preferences.json')
}
