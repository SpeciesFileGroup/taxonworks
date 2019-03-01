import ajaxCall from 'helpers/ajaxCall'

const GetMetadata = function () {
  return ajaxCall('get', '/hub/tasks?category=source')
}

const GetRecentSources = function () {
  return ajaxCall('get', '/sources.json?recent=true&per=20')
}

const GetCitationsFromSourceID = function (id) {
  return ajaxCall('get', `/citations.json?source_id=${id}`)
}

const GetDocumentsFromSourceID = function (id) {
  return ajaxCall('get', `/sources/${id}/documentation.json`)
}

const GetMetadataSource = function () {
  return ajaxCall('get', '/metadata/Source')
}

const GetMetadataProjectSource = function () {
  return ajaxCall('get', '/metadata/ProjectSource')
}

const GetSourceTags = function (id) {
  return ajaxCall('get', `/sources/${id}/tags.json`)
}

export {
  GetMetadata,
  GetRecentSources,
  GetCitationsFromSourceID,
  GetDocumentsFromSourceID,
  GetMetadataSource,
  GetMetadataProjectSource,
  GetSourceTags
}