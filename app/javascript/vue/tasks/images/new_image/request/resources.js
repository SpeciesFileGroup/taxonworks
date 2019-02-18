import ajaxCall from 'helpers/ajaxCall'

const GetLicenses = function () {
  return ajaxCall('get', '/attributions/licenses')
}

const GetCollectingEventSmartSelector = function () {
  return ajaxCall('get', '/collecting_events/select_options')
}

const GetCollectionObjectSmartSelector = function () {
  return ajaxCall('get', '/collection_objects/select_options')
}

const GetOtuSmartSelector = function () {
  return ajaxCall('get', '/otus/select_options')
}

const GetSqedMetadata = function () {
  return ajaxCall('get', '/sqed_depictions/metadata_options')
}

const GetSourceSmartSelector = function () {
  return ajaxCall('get', '/sources/select_options')
}

const CreateAttribution = function (data) {
  return ajaxCall('post', '/attributions.json', { attribution: data })
}

const CreateDepiction = function (data) {
  return ajaxCall('post', '/depictions.json', { depiction: data })
}

const UpdateAttribution = function (data) {
  return ajaxCall('patch', `/attributions/${data.id}.json`, { attribution: data })
}

const UpdateDepiction = function (data) {
  return ajaxCall('patch', `/depictions/${data.id}.json`, { depiction: data })
}

const DestroyImage = function (id) {
  return ajaxCall('delete', `/images/${id}.json`)
}

export {
  CreateAttribution,
  CreateDepiction,
  GetLicenses,
  GetCollectingEventSmartSelector,
  GetCollectionObjectSmartSelector,
  GetSourceSmartSelector,
  GetSqedMetadata,
  GetOtuSmartSelector,
  UpdateAttribution,
  UpdateDepiction,
  DestroyImage
}