import ajaxCall from 'helpers/ajaxCall'

const GetTaxonName = (id) => ajaxCall('get', `/taxon_names/${id}.json`)

const GetOtu = (id) => ajaxCall('get', `/otus/${id}.json`)

const GetOtus = (params) => ajaxCall('get', '/otus.json', { params: params })

const GetPeople = (id) => {
  return ajaxCall('get', `/people/${id}.json`)
}

export {
  GetTaxonName,
  GetOtu,
  GetOtus,
  GetPeople
}
