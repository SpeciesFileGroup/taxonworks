import RadialCollectionObject from '@/components/radials/co/radial.vue'
import { COLLECTION_OBJECT } from '@/constants'

const COMPONENTS = {
  [COLLECTION_OBJECT]: RadialCollectionObject
}

export function getRadialComponent(objectType) {
  return COMPONENTS[objectType]
}
