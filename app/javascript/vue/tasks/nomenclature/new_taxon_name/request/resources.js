import ajaxCall from 'helpers/ajaxCall'

const loadSoftValidation = (globalId) => ajaxCall('get', '/soft_validations/validate', { params: { global_id: globalId } })

const GetTypeMaterial = (taxonId) => ajaxCall('get', `/type_materials.json?protonym_id=${taxonId}`)

const GetPredictedRank = (parentId, name) => ajaxCall('get', '/taxon_names/predicted_rank', { params: { parent_id: parentId, name: name }})

export {
  loadSoftValidation,
  GetTypeMaterial,
  GetPredictedRank
}
