import ajaxCall from 'helpers/ajaxCall'

const CreateAssertedDistribution = function(data) {
  return ajaxCall('post', '/asserted_distributions.json', { asserted_distribution: data })
}

const GetSourceSmartSelector = function() {
  return ajaxCall('get', '/sources/select_options.json')
}

const GetOtuSmartSelector = function() {
  return ajaxCall('get', '/otus/select_options.json?target=AssertedDistribution')
}

const GetGeographicAreaSmartSelector = function() {
  return ajaxCall('get', '/geographic_areas/select_options.json?target=AssertedDistribution')
}

const RemoveAssertedDistribution = function(id) {
  return ajaxCall('delete', `/asserted_distributions/${id}.json`)
}

const UpdateAssertedDistribution = function(data) {
  return ajaxCall('patch', `/asserted_distributions/${data.id}.json`, { asserted_distribution: data })
}

export {
  CreateAssertedDistribution,
  GetSourceSmartSelector,
  GetOtuSmartSelector,
  GetGeographicAreaSmartSelector,
  RemoveAssertedDistribution,
  UpdateAssertedDistribution
}