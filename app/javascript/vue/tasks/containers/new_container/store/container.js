import { defineStore } from 'pinia'
import { Container, ContainerItem } from '@/routes/endpoints'
import {
  makeContainer,
  makeContainerPayload,
  makeContainerItem,
  makeContainerItemPayload
} from '../adapters'
import { removeFromArray, addToArray } from '@/helpers'
import {
  comparePosition,
  isItemInContainer,
  makeVisualizerContainerItem
} from '../utils'
import { DEFAULT_OPTS, CONTAINER_PARAMETERS } from '../constants'
import { useObjectStore } from './objects'

export const useContainerStore = defineStore('container', {
  state: () => ({
    placeItem: null,
    isLoading: false,
    isSaving: false,
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

    getContainerItemByObject(state) {
      return ({ objectId, objectType }) =>
        state.containerItems.find(
          (item) => item.objectId === objectId && item.objectType === objectType
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
        state.selectedItems.find((item) => item.metadata?.uuid === uuid)
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

    containerSlots(state) {
      return (
        state.container.size.x * state.container.size.y * state.container.size.z
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

      return Container.find(id, CONTAINER_PARAMETERS)
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
      if (
        !this.selectedItems.some(
          (i) => i.uuid === item.uuid || i.metadata?.uuid === item.uuid
        )
      ) {
        this.selectedItems.push(makeVisualizerContainerItem(item, this))
      }
    },

    fillContainer(items, { direction }) {
      const { size } = this.container

      for (let i = 0; i < size[direction[2]]; i++) {
        for (let j = 0; j < size[direction[1]]; j++) {
          for (let k = 0; k < size[direction[0]]; k++) {
            const position = {
              [direction[2]]: i,
              [direction[1]]: j,
              [direction[0]]: k
            }
            const cellItem = this.getContainerItemByPosition(position)

            if (!cellItem && items.length) {
              const item = items.shift()
              const containerItem = {
                ...item,
                position,
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
        (i) => i.metadata?.uuid === item.uuid || i.uuid === item.uuid
      )

      if (index > -1) {
        this.selectedItems.splice(index, 1)
      }
    },

    removeContainerItem(item) {
      const store = useObjectStore()

      if (item.id) {
        ContainerItem.destroy(item.id).then(() => {
          TW.workbench.alert.create(
            'Container item was successfully destroyed.'
          )
        })
      }

      store.addObject({
        ...makeContainerItem(),
        objectId: item.objectId,
        objectType: item.objectType,
        label: item.label
      })

      removeFromArray(this.containerItems, item, { property: 'uuid' })
    },

    saveContainerItems() {
      if (!this.container.id) return
      this.isSaving = true

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

        request
          .then(({ body }) => {
            item.id = body.id
            item.isUnsaved = false
            item.errorOnSave = false
          })
          .catch(({ response }) => {
            item.isUnsaved = false
            item.errorOnSave = Object.values(response.body).join('; ')
          })

        return request
      })

      Promise.all(promises)
        .then(() => {
          if (promises.length) {
            const message =
              promises.length === 1
                ? 'Container item was successfully saved.'
                : `${promises.length} Container items were successfully saved.`

            TW.workbench.alert.create(message)
          }
        })
        .catch(() => {})
        .finally(() => (this.isSaving = false))
    },

    unplaceSelected() {
      const items = this.selectedItems.filter((item) => item.metadata?.uuid)

      items.forEach(({ metadata }) => {
        const obj = this.containerItems.find(
          (item) => item.uuid === metadata.uuid
        )

        Object.assign(obj, {
          position: {
            x: null,
            y: null,
            z: null
          },
          isUnsaved: true
        })
      })
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
