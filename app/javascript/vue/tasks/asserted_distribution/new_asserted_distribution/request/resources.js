import ajaxCall from 'helpers/ajaxCall'

const CreateAssertedDistribution = (data) => {
  return ajaxCall('post', '/asserted_distributions.json', { asserted_distribution: data })
}

const GetAssertedDistribution = (params) => ajaxCall('get', '/asserted_distributions.json', { params: params })

const GetGeographicArea = (id) => {
  return ajaxCall('get', `/geographic_areas/${id}.json`)
}

const GetSource = (id) => {
  return ajaxCall('get', `/sources/${id}.json`)
}

const GetOtu = (id) => {
  return ajaxCall('get', `/otus/${id}.json`)
}

const RemoveAssertedDistribution = (id) => {
  return ajaxCall('delete', `/asserted_distributions/${id}.json`)
}

const UpdateAssertedDistribution = (data) => {
  return ajaxCall('patch', `/asserted_distributions/${data.id}.json`, { asserted_distribution: data })
}

const LoadRecentRecords = () => {
  return ajaxCall('get', '/asserted_distributions.json?recent=true&per=15')
}

export {
  GetSource,
  GetOtu,
  GetGeographicArea,
  GetAssertedDistribution,
  CreateAssertedDistribution,
  RemoveAssertedDistribution,
  UpdateAssertedDistribution,
  LoadRecentRecords
}
