import { defineStore } from 'pinia'
import { Container, ContainerItem } from '@/routes/endpoints'
import {
  makeContainer,
  makeContainerPayload,
  makeContainerItem,
  makeContainerItemPayload
} from '../adapters'
import { removeFromArray, addToArray, shorten } from '@/helpers'
import { comparePosition } from '../utils'

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

function makeVisualizerContainerItem(item, { truncateMaxLength, hoverRow }) {
  const label = truncateMaxLength
    ? shorten(item.label, truncateMaxLength)
    : item.label
  const style =
    hoverRow && comparePosition(item.position, hoverRow.position)
      ? { color: HOVER_COLOR }
      : {}

  return {
    position: item.position,
    metadata: item,
    label,
    style
  }
}

function isItemInContainer({ x, y, z }, size) {
  return (
    x !== null &&
    y !== null &&
    z !== null &&
    x < size.x &&
    y < size.y &&
    z < size.z
  )
}

export const useContainerStore = defineStore('container', {
  state: () => ({
    placeItem: null,
    isLoading: false,
    truncateMaxLength: 50,
    container: makeContainer(),
    containerItems: [],
    hoverRow: null,
    selectedItems: []
  }),

  getters: {
    encaseOpts(state) {
      const containerItems = state.containerItems.map((item) =>
        makeVisualizerContainerItem(item, state)
      )

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

    getSelectedContainerItemByPosition(state) {
      return (coordinates) =>
        state.selectedItems.find(({ position }) =>
          comparePosition(coordinates, position)
        )
    },

    getSelectedContainerItemByUUID(state) {
      return (uuid) =>
        state.selectedItems.find((item) => item.metadata.uuid === uuid)
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
    },

    isItemInside(state) {
      return (item) => {
        return state.getItemsInsideContainer.some((i) =>
          comparePosition(i.position, item.position)
        )
      }
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

    addSelectedItem(item) {
      if (!this.selectedItems.some((i) => i.metadata.uuid === item.uuid)) {
        this.selectedItems.push(makeVisualizerContainerItem(item, this))
      }
    },

    fillContainer(items) {
      const { size } = this.container

      for (let y = 0; y < size.y; y++) {
        for (let z = 0; z < size.z; z++) {
          for (let x = 0; x < size.x; x++) {
            const cellItem = this.getContainerItemByPosition({ x, y, z })

            if (!cellItem && items.length) {
              const item = items.shift()
              const containerItem = {
                ...item,
                position: {
                  x,
                  y,
                  z
                },
                isUnsaved: true
              }

              this.addContainerItem(containerItem)
            }
          }
        }
      }
    },

    removeSelectedItem(item) {
      const index = this.selectedItems.findIndex(
        (i) => i.metadata.uuid === item.uuid
      )

      if (index > -1) {
        this.selectedItems.splice(index, 1)
      }
    },

    removeContainerItem(item) {
      if (item.id) {
        ContainerItem.destroy(item.id).then(() => {
          TW.workbench.alert.create(
            'Container item was successfully destroyed.'
          )
        })
      }

      removeFromArray(this.containerItems, item, { property: 'uuid' })
    },

    saveContainerItems() {
      if (!this.container.id) return

      const unsavedItems = this.containerItems.filter((item) => item.isUnsaved)
      const list = unsavedItems.filter((item) =>
        isItemInContainer(item.position, this.container.size)
      )
      const outsideItemsCount = unsavedItems.length - list.length
      let message = ''

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

        request
          .then(({ body }) => {
            item.id = body.id
            item.isUnsaved = false
          })
          .catch(() => {})

        return request
      })

      if (outsideItemsCount) {
        if (outsideItemsCount === 1) {
          message = `Container items was not saved because its position exceeds the container size.`
        } else {
          message = `${outsideItemsCount} were not saved because their position exceeds the container size.`
        }
      }

      Promise.all(promises)
        .then(() => {
          if (promises.length) {
            message +=
              promises.length === 1
                ? 'Container item was successfully saved.'
                : `${promises.length} Container items were successfully saved.`

            TW.workbench.alert.create(message)
          }
        })
        .catch(() => {})
    },

    saveContainer() {
      const payload = { container: makeContainerPayload(this.container) }
      const request = this.container.id
        ? Container.update(this.container.id, payload)
        : Container.create(payload)

      request
        .then(({ body }) => {
          this.container = makeContainer(body)
          TW.workbench.alert.create('Container was successfully saved.')
        })
        .catch(() => {})

      return request
    }
  }
})
