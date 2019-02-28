import ajaxCall from 'helpers/ajaxCall'

const GetMetadata = function () {
  return ajaxCall('get', '/hub/tasks?category=source')
}

const GetRecentSources = function () {
  return ajaxCall('get', '/sources.json?recent=true&per=20')
}

export {
  GetMetadata,
  GetRecentSources
}