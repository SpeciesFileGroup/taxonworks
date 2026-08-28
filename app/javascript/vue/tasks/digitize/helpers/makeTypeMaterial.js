import { TYPE_MATERIAL } from '@/constants'
import makeTypeMaterial from '@/factory/TypeMaterial.js'
import makeCitation from '@/factory/Citation.js'

export default function (typeData = {}) {
  return {
    ...makeTypeMaterial(typeData),
    citation: makeCitation(TYPE_MATERIAL),
    data_attributes_attributes: []
  }
}
