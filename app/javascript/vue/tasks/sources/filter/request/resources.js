import ajaxCall from 'helpers/ajaxCall'

const GetSources = (params) => {
  return ajaxCall('get', '/sources.json', { params: params })
}

const GetUsers = () => {
  return ajaxCall('get', '/project_members.json')
}

const GetNamespace = (id) => {
  return ajaxCall('get', `/namespaces/${id}.json`)
}

const GetPeople = (id) => {
  return ajaxCall('get', `/people/${id}.json`)
}

const GetSerial = (id) => {
  return ajaxCall('get', `/serials/${id}.json`)
}

const GetCitationTypes = () => {
  return ajaxCall('get', '/sources/citation_object_types.json')
}

const GetBibtex = (params) => {
  return ajaxCall('get', '/sources.bib', params)
}

const GetBibtexStyle = () => ajaxCall('get', '/sources/csl_types')

const GetBibliography = (params) => ajaxCall('get', '/sources/generate.json', params)

const GetGenerateLinks = (params) => {
  return ajaxCall('get', '/sources/generate', { params: params })
}

const GetKeyword = (id) => {
  return ajaxCall('get', `/controlled_vocabulary_terms/${id}.json`)
}

export {
  GetSources,
  GetUsers,
  GetCitationTypes,
  GetBibtex,
  GetGenerateLinks,
  GetNamespace,
  GetPeople,
  GetKeyword,
  GetBibtexStyle,
  GetBibliography,
  GetSerial
}
