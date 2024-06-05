import { makeContainerItem } from './makeContainerItem'

export function makeContainer(container = {}) {
  return {
    id: container.id,
    name: container.name,
    type: container.type,
    size: {
      x: container.size_x || 0,
      y: container.size_y || 0,
      z: container.size_z || 0
    },
    containerItems: container.container_items?.map(makeContainerItem) || []
  }
}
