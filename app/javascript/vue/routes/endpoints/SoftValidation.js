import { filterParams } from './base'
import AjaxCall from 'helpers/ajaxCall'

const permitParams = {
  only_sets: [],
  only_methods: [],
  except_methods: [],
  except_sets: []
}

export const SoftValidation = {
  fix: (globalId, params) => AjaxCall('post', `/soft_validations/fix?global_id=${globalId}`, filterParams(params, permitParams)),

  find: (globalId) => AjaxCall('get', '/soft_validations/validate', { params: { global_id: globalId } })
}
