import { defineStore } from 'pinia'

export default defineStore('reclassifier-interaction', {
  state: () => ({
    currentDragged: {},
    isLoading: false,
    selected: {},
    isDragging: false
  }),

  getters: {
    getSelectedItemsByGroup(state) {
      return (group) =>
        state.selected[group]
          ? state.selected[group].filter(
              (item) => item.id !== state.currentDragged.taxon.id
            )
          : []
    }
  },

  actions: {
    setCurrentDraggedTaxon(value) {
      this.currentDragged = value
    },

    addSelected(item, group) {
      const selectedItems = this.selected[group]

      if (selectedItems) {
        const index = selectedItems.findIndex((t) => t.id === item.id)

        if (index > -1) {
          selectedItems.splice(index, 1)
        } else {
          selectedItems.push(item)
        }
      } else {
        this.selected[group] = [item]
      }
    }
  }
})
