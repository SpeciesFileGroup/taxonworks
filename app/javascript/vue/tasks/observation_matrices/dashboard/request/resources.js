import ajaxCall from 'helpers/ajaxCall'

const GetTaxonName = (id) => {
  return ajaxCall('get', `/taxon_names/${id}.json`)
}

const LoadRanks = () => {
  return ajaxCall('get', '/taxon_names/ranks')
}

const GetRanksTable = (ancestor, params) => {
  return ajaxCall('get', `/taxon_names/rank_table`, { params: params })
}

export {
  GetTaxonName,
  LoadRanks,
  GetRanksTable
}
