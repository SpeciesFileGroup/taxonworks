import ajaxCall from 'helpers/ajaxCall'

const GetSequenceSmartSelector = function() {
  return ajaxCall('get', '/sequences/select_options.json')
}

export {
  GetSequenceSmartSelector,
}