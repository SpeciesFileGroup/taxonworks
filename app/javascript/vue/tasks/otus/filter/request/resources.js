import ajaxCall from 'helpers/ajaxCall'

const GetTaxonName = (id) => ajaxCall('get', `/taxon_names/${id}.json`)

const GetOtu = (id) => ajaxCall('get', `/otus/${id}.json`)

export {
  GetTaxonName,
  GetOtu
}
