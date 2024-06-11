import { defineStore } from 'pinia'
import { Container, ContainerItem } from '@/routes/endpoints'
import {
  makeContainer,
  makeContainerPayload,
  makeContainerItem,
  makeContainerItemPayload
} from '../adapters'
import { removeFromArray, addToArray } from '@/helpers'

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

    hasUnsavedChanges(state) {
      return (
        state.containerItems.some((item) => item.isUnsaved) ||
        state.container.isUnsaved
      )
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
          this.containerItems =
            body.container_items?.map(makeContainerItem) || []
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
      addToArray(this.containerItems, item, { property: 'uuid' })
    },

    removeContainerItem(item) {
      if (item.id) {
        ContainerItem.destroy(item.id)
      }

      removeFromArray(this.containerItems, item, { property: 'uuid' })
    },

    saveContainerItems() {
      if (!this.container.id) return

      const list = this.containerItems.filter((item) => item.isUnsaved)
      const promises = list.map((item) => {
        const payload = {
          container_item: makeContainerItemPayload({
            ...item,
            containerId: this.container.id
          })
        }

        const request = item.id
          ? ContainerItem.update(item.id, payload)
          : ContainerItem.create(payload)

        request.catch(() => {})

        return request
      })

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
