import AjaxCall from 'helpers/ajaxCall'

export const SqedDepiction = {
  metadata: () => AjaxCall('get', '/sqed_depictions/metadata_options')
}
