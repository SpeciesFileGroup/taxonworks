import { defineStore } from 'pinia'

export default defineStore('settings', {
  state: () => ({
    treeView: false,
    isLoading: false
  })
})
