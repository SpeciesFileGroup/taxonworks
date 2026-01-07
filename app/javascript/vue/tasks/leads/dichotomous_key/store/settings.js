import { defineStore } from 'pinia'

export default defineStore('settings', {
  state: () => ({
    treeView: true,
    isLoading: true
  })
})
