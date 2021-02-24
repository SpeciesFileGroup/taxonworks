import ajaxCall from 'helpers/ajaxCall'

const GetSources = (params) => ajaxCall('get', '/sources.json', { params: params })

const GetUsers = () => ajaxCall('get', '/project_members.json')

const GetNamespace = (id) => ajaxCall('get', `/namespaces/${id}.json`)

const GetPeople = (id) => ajaxCall('get', `/people/${id}.json`)

const GetSerial = (id) => ajaxCall('get', `/serials/${id}.json`)

const GetCitationTypes = () => ajaxCall('get', '/sources/citation_object_types.json')

const GetBibtex = (params) => ajaxCall('get', '/sources.bib', params)

const GetBibtexStyle = () => ajaxCall('get', '/sources/csl_types')

const GetBibliography = (params) => ajaxCall('get', '/sources/generate.json', params)

const GetGenerateLinks = (params) => ajaxCall('get', '/sources/generate', { params: params })

const GetKeyword = (id) => ajaxCall('get', `/controlled_vocabulary_terms/${id}.json`)

const GetTaxonName = (id) => ajaxCall('get', `/taxon_names/${id}.json`)

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
  GetSerial,
  GetTaxonName
}
