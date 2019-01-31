import ajaxCall from 'helpers/ajaxCall'

const GetLicenses = function () {
  return ajaxCall('get', '/attributions/licenses')
}

const GetCollectingEventSmartSelector = function () {
  return ajaxCall('get', '/collecting_events/select_options', { params: { target: 'Depiction' } })
}

const GetCollectionObjectSmartSelector = function () {
  return ajaxCall('get', '/collection_objects/select_options', { params: { target: 'Depiction' } })
}

const GetOtuSmartSelector = function () {
  return ajaxCall('get', '/otus/select_options', { params: { target: 'Depiction' } })
}

const GetSourceSmartSelector = function () {
  return ajaxCall('get', '/sources/select_options')
}

export {
  GetLicenses,
  GetCollectingEventSmartSelector,
  GetCollectionObjectSmartSelector,
  GetSourceSmartSelector,
  GetOtuSmartSelector
}