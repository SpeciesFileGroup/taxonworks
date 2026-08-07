import { filterParams } from './base'
import AjaxCall from '@/helpers/ajaxCall'

const permitParams = {
  only_sets: [],
  only_methods: [],
  except_methods: [],
  except_sets: []
}

export const SoftValidation = {
  fix: (globalId, params) =>
    AjaxCall(
      'post',
      `/soft_validations/fix?global_id=${globalId}`,
      filterParams(params, permitParams)
    ),

  // TODO: axiosConfig (cancelRequest etc.) is passed as AjaxCall's 4th arg, which
  // axios.get silently ignores — cancellation has never worked for this endpoint.
  find: (globalId, config = {}) => {
    const { params: extraParams = {}, ...axiosConfig } = config
    return AjaxCall(
      'get',
      '/soft_validations/validate',
      { params: { global_id: globalId, ...extraParams } },
      axiosConfig
    )
  }
}
