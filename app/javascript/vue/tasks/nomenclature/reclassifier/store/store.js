import { defineStore } from 'pinia'
import { TaxonName } from '@/routes/endpoints'
import { buildTree } from '../utils'

export default function (treeName) {
  return defineStore(`reclassifier-${treeName}`, {
    state: () => ({
      tree: [],
      treeLeft: [],
      isLoading: false
    }),

    actions: {
      async loadTree(params) {
        try {
          this.isLoading = true

          const { body } = await TaxonName.filter({
            ...params,
            ancestrify: true,
            per: 2000
          })

          const tree = buildTree(body)

          this.setTree(tree)

          return tree
        } catch {
        } finally {
          this.isLoading = false
        }
      },

      setTree(tree) {
        this.tree = tree
      }
    }
  })
}
