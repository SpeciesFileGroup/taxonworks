import { makeContainerItem } from './makeContainerItem'

export function makeContainer(container = {}) {
  return {
    id: container.id,
    name: container.name,
    type: container.type,
    sizeX: container.size_x,
    sizeY: container.size_y,
    sizeZ: container.size_z,
    containerItems: container.container_items?.map(makeContainerItem) || []
  }
}
