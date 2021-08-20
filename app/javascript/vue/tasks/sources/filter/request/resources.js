import ajaxCall from 'helpers/ajaxCall'

const GetCitationTypes = () => ajaxCall('get', '/sources/citation_object_types.json')

const GetBibtex = (params) => ajaxCall('get', '/sources.bib', params)

const GetBibtexStyle = () => ajaxCall('get', '/sources/csl_types')

const GetBibliography = (params) => ajaxCall('get', '/sources/generate.json', params)

const GetGenerateLinks = (params) => ajaxCall('get', '/sources/generate', { params: params })

export {
  GetCitationTypes,
  GetBibtex,
  GetGenerateLinks,
  GetBibtexStyle,
  GetBibliography
}
