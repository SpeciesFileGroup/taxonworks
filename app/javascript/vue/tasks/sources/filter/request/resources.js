import ajaxCall from 'helpers/ajaxCall'

const GetSources = (params) => {
  return ajaxCall('get', '/sources.json', { params: params })
}

const GetUsers = () => {
  return ajaxCall('get', '/project_members.json')
}

const GetCitationTypes = () => {
  return ajaxCall('get', '/sources/citation_object_types.json')
}

const GetBibtex = (params) => {
  return ajaxCall('get', '/sources.bib', { params: params })
}

const GetGenerateLinks = (params) => {
  return ajaxCall('get', '/sources/generate', { params: params })
}

export {
  GetSources,
  GetUsers,
  GetCitationTypes,
  GetBibtex,
  GetGenerateLinks
}
