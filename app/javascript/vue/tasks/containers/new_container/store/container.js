import { defineStore } from 'pinia'
import { Container, ContainerItem } from '@/routes/endpoints'
import {
  makeContainer,
  makeContainerPayload,
  makeContainerItem,
  makeContainerItemPayload
} from '../adapters'
import { removeFromArray, addToArray, shorten } from '@/helpers'

const HOVER_COLOR = {
  filled: 'blue',
  empty: 'blue',
  selected: 'blue'
}

const DEFAULT_OPTS = {
  enclose: true,
  itemSize: 1,
  padding: 1,
  cameraPosition: {
    x: 50,
    y: 50,
    z: 50
  }
}

function comparePosition({ x, y, z }, position) {
  return position.x === x && position.y === y && position.z === z
}

function isItemInContainer({ x, y, z }, size) {
  return (
    x !== null &&
    y !== null &&
    z !== null &&
    x <= size.x &&
    y <= size.y &&
    z <= size.z
  )
}

export const useContainerStore = defineStore('container', {
  state: () => ({
    placeItem: null,
    isLoading: false,
    truncateMaxLength: 50,
    container: makeContainer(),
    containerItems: [],
    hoverRow: null
  }),

  getters: {
    encaseOpts(state) {
      const containerItems = state.containerItems.map((item) => {
        return {
          ...item,
          label: state.truncateMaxLength
            ? shorten(item.label, state.truncateMaxLength)
            : item.label,
          style:
            state.hoverRow &&
            comparePosition(item.position, state.hoverRow.position)
              ? {
                  color: HOVER_COLOR
                }
              : {}
        }
      })

      return {
        ...DEFAULT_OPTS,
        container: {
          type: state.container.type,
          sizeX: state.container.size.x,
          sizeY: state.container.size.y,
          sizeZ: state.container.size.z,
          containerItems
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
    },

    getItemsOutsideContainer(state) {
      return state.containerItems.filter(
        (item) => !isItemInContainer(item.position, this.container.size)
      )
    },

    getItemsInsideContainer(state) {
      return state.containerItems.filter((item) =>
        isItemInContainer(item.position, this.container.size)
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

      Promise.all(promises).catch(() => {})
    },

    saveContainer() {
      const payload = { container: makeContainerPayload(this.container) }
      const request = this.container.id
        ? Container.update(this.container.id, payload)
        : Container.create(payload)

      request
        .then(({ body }) => {
          this.container = makeContainer(body)
        })
        .catch(() => {})
    }
  }
})
