import ajaxCall from 'helpers/ajaxCall'

const GetInteractiveKey = (id, params) => ajaxCall('get', `/tasks/observation_matrices/interactive_key/${id}/key`, { params: params })

const GetCharacterStateDepictions = function (id) {
  return ajaxCall('get', `/character_states/${id}/depictions.json`)
}

const GetDescriptorDepictions = function (id) {
  return ajaxCall('get', `/descriptors/${id}/depictions.json`)
}

export {
  GetInteractiveKey,
  GetCharacterStateDepictions,
  GetDescriptorDepictions
}
