import { defineStore } from 'pinia'
import { TaxonName } from '@/routes/endpoints'
import { buildTree } from '../utils'

export default defineStore('reclassifier', {
  state: () => ({
    currentDragged: {},
    treeRight: [],
    treeLeft: [],
    isLoading: false,
    selected: {},
    isDragging: false
  }),

  actions: {
    loadTree(params, side) {
      this.isLoading = true

      TaxonName.filter({ ...params, ancestrify: true, per: 2000 })
        .then(({ body }) => {
          const tree = buildTree(body)

          switch (side) {
            case 'left':
              this.treeLeft = tree
              break
            case 'right':
              this.treeRight = tree
              break
            default:
              this.treeLeft = tree
              this.treeRight = structuredClone(tree)
          }
        })
        .finally(() => {
          this.isLoading = false
        })
    },

    setCurrentDraggedTaxon(value) {
      this.currentDragged = value
    }
  }
})
