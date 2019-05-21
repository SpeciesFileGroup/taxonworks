import ajaxCall from 'helpers/ajaxCall'

const GetSequenceSmartSelector = () => {
  return ajaxCall('get', '/sequences/select_options.json')
}

const GetProtocolSmartSelector = () => {
  return ajaxCall('get', '/protocols/select_options.json')
}

export {
  GetSequenceSmartSelector,
  GetProtocolSmartSelector
}