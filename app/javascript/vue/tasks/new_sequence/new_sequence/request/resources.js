import ajaxCall from 'helpers/ajaxCall'

const GetSequenceSmartSelector = () => {
  return ajaxCall('get', '/sequences/select_options')
}

const GetProtocolSmartSelector = () => {
  return ajaxCall('get', '/protocols/select_options')
}

const GetCollectionObjectSmartSelector = () => {
  return ajaxCall('get', '/collection_objects/select_options')
}

const GetOtuSmartSelector = () => {
  return ajaxCall('get', '/otus/select_options')
}

const GetExtractSmartSelector = () => {
  return ajaxCall('get', '/extracts/select_options')
}

export {
  GetSequenceSmartSelector,
  GetProtocolSmartSelector,
  GetCollectionObjectSmartSelector,
  GetOtuSmartSelector,
  GetExtractSmartSelector
}