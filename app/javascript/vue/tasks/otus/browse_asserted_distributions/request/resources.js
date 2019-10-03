import ajaxCall from 'helpers/ajaxCall'

const GetOtuAssertedDistribution = (data) => {
  return ajaxCall('get', `/asserted_distributions.json`, { params: data })
}

const GetOtu = (id) => {
  return ajaxCall('get', `/otus/${id}`)
}

export {
  GetOtuAssertedDistribution,
  GetOtu
}
