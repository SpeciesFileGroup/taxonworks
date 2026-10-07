import { defineStore } from 'pinia'

export const useSettingsStore = defineStore('settings', {
  state: () => ({
    isLoading: false,
    hideEmptyPanels: false,
    emptyPanels: {}
  }),

  getters: {
    isPanelHidden: (state) => (name) =>
      state.hideEmptyPanels && state.emptyPanels[name] === true
  },

  actions: {
    setPanelIsEmpty(name, isEmpty) {
      this.emptyPanels[name] = isEmpty
    },

    unregisterPanel(name) {
      delete this.emptyPanels[name]
    }
  }
})
