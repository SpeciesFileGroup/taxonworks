import ajaxCall from 'helpers/ajaxCall'

const GetSources = (params) => {
  return ajaxCall('get', '/sources.json', { params: params })
}

const GetUsers = () => {
  return ajaxCall('get', '/project_members.json')
}

const GetCollectingEventSmartSelector = () => {
  return ajaxCall('get', '/collecting_events/select_options')
}

const GetKeywordSmartSelector = () => {
  return ajaxCall('get', '/keywords/select_options?klass=CollectionObject')
}

export {
  GetSources,
  GetUsers,
  GetCollectingEventSmartSelector,
  GetKeywordSmartSelector
}
