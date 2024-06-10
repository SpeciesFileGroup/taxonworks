import { defineStore } from 'pinia'
import { Container, ContainerItem } from '@/routes/endpoints'
import {
  makeContainer,
  makeContainerPayload,
  makeContainerItemPayload
} from '../adapters'

const DEFAULT_OPTS = {
  enclose: true,
  itemSize: 1,
  padding: 1
}

function comparePosition({ x, y, z }, position) {
  return position.x === x && position.y === y && position.z === z
}

export const useContainerStore = defineStore('container', {
  state: () => ({
    isLoading: false,
    container: makeContainer(),
    containerItems: []
  }),

  getters: {
    encaseOpts(state) {
      return {
        ...DEFAULT_OPTS,
        container: {
          type: state.container.type,
          sizeX: state.container.size.x,
          sizeY: state.container.size.y,
          sizeZ: state.container.size.z,
          containerItems: this.containerItems
        }
      }
    },

    getContainerItemByPosition(state) {
      return (coordinates) =>
        state.containerItems.find(({ position }) =>
          comparePosition(coordinates, position)
        )
    }
  },

  actions: {
    async loadContainer(id) {
      this.isLoading = true

      return Container.find(id)
        .then(({ body }) => {
          this.container = makeContainer(body)
        })
        .catch(() => {})
        .finally(() => {
          this.isLoading = false
        })
    },

    async loadContainerItems(containerId) {
      this.isLoading = true

      return ContainerItem.where({ container_id: containerId })
        .then(({ body }) => {
          this.container = makeContainer(body)
        })
        .catch(() => {})
        .finally(() => {
          this.isLoading = false
        })
    },

    newContainer() {
      this.container = makeContainer()
    },

    addContainerItem(item) {
      const index = this.containerItems.findIndex(({ position }) =>
        comparePosition(item.position, position)
      )

      if (index > -1) {
        this.containerItems[index] = item
      } else {
        this.containerItems.push(item)
      }
    },

    saveContainerItems() {
      const list = this.containerItems.filter((item) => item.isUnsaved)

      const promises = list.map((item) =>
        item.id
          ? ContainerItem.update(item.id, {
              container_item: makeContainerItemPayload(item)
            })
          : ContainerItem.create({
              container_item: makeContainerItemPayload(item)
            })
      )

      Promise.all(promises)
    },

    saveContainer() {
      Container.create({
        container: makeContainerPayload(this.container)
      })
        .then(({ body }) => {
          this.container = makeContainer(body)
        })
        .catch(() => {})
    }
  }
})
