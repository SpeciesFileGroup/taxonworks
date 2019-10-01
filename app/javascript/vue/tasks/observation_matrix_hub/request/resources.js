import ajaxCall from 'helpers/ajaxCall'

const GetObservation = (id) => {
  return ajaxCall('get', `/observation_matrices/${id}.json`)
}

export {
  GetObservation
}
