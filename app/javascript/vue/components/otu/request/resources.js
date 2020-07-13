import ajaxCall from 'helpers/ajaxCall'

const GetOtus = (id) => {
  return ajaxCall('get', `/taxon_names/${id}/otus.json`, { 
    headers: {
      'Cache-Control': 'no-cache'
    }
  })
}

const CreateOtu = (id) => {
  return ajaxCall('post', `/otus`, { otu: { taxon_name_id: id } })
}

const GetOtu = (id) => {
  return ajaxCall('get', `/otus/${id}.json`)
}

export {
  GetOtu,
  GetOtus,
  CreateOtu
}
