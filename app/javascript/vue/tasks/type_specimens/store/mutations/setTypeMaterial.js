import setParamsId from 'helpers/setParam.js'
import { RouteNames } from 'routes/routes'

export default (state, material) => {
  setParamsId(RouteNames.TypeMaterial, 'type_material_id', material.id)
  state.type_material.origin_citation = undefined
  state.type_material.origin_citation_attributes = {
    source_id: undefined,
    pages: undefined
  }

  state.type_material = Object.assign({}, state.type_material, material)
}
