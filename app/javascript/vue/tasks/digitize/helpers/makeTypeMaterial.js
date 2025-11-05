import { TYPE_MATERIAL } from '@/constants'
import makeTypeMaterial from '@/factory/TypeMaterial.js'
import makeCitation from '@/factory/Citation.js'

export default function () {
  return {
    ...makeTypeMaterial(),
    citation: makeCitation(TYPE_MATERIAL)
  }
}
