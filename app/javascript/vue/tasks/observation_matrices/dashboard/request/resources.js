import ajaxCall from 'helpers/ajaxCall'

const GetTaxonName = (id) => {
  return ajaxCall('get', `/taxon_names/${id}.json`)
}

const LoadRanks = () => {
  return ajaxCall('get', '/taxon_names/ranks')
}

const GetRanksTable = (params) => {
  return ajaxCall('get', `/taxon_names/rank_table`, { params: params })
}

const GetObservationMatrices = () => {
  return ajaxCall('get', `/observation_matrices.json`)
}

const GetObservationMatrix = (id) => {
  return ajaxCall('get', `/observation_matrices/${id}.json`)
}

const GetObservationRow = (params) => {
  return ajaxCall('get', '/observation_matrix_rows.json', { params: params })
}

const CreateObservationMatrixRow = (data) => {
  return ajaxCall('post', `/observation_matrix_row_items.json`, { observation_matrix_row_item: data })
}

const CreateOTU = (taxonId) => ajaxCall('post', '/otus.json', { otu: { taxon_name_id: taxonId } })

export {
  CreateObservationMatrixRow,
  GetObservationMatrix,
  GetTaxonName,
  LoadRanks,
  GetRanksTable,
  GetObservationMatrices,
  GetObservationRow,
  CreateOTU
}
