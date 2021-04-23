import AjaxCall from 'helpers/ajaxCall'

const SoftValidationFix = (params) => AjaxCall('post', `/soft_validations/fix?global_id=${params.global_id}`, params)

export {
  SoftValidationFix
}
