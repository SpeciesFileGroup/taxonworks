import { defineStore } from 'pinia'
import { TaxonName } from '@/routes/endpoints'

function makeTaxonNodeWithState(taxon) {
  return {
    ...makeTaxonNode(taxon),
    isLoaded: false,
    isExpanded: true
  }
}

function makeTaxonNode(taxon) {
  return {
    id: taxon.id,
    name: [taxon.cached_html, taxon.cached_author_year].join(' '),
    parentId: taxon.parent_id,
    isValid: taxon.cached_is_valid,
    synonyms: taxon.synonyms || [],
    children: []
  }
}

function buildTree(data) {
  const nodesById = new Map()

  data.forEach((item) => {
    nodesById.set(item.id, makeTaxonNodeWithState(item))
  })

  const roots = []

  data.forEach((item) => {
    const node = nodesById.get(item.id)

    if (item.parent_id === null) {
      roots.push(node)
    } else {
      const parent = nodesById.get(item.parent_id)
      if (parent) {
        parent.children.push(node)
      } else {
        roots.push(node)
      }
    }
  })

  return roots
}

export default defineStore('reclassifier', {
  state: () => ({
    currentDragged: {},
    tree: {},
    treeRight: [],
    treeLeft: [],
    taxonNames: []
  }),

  actions: {
    loadTree(params) {
      TaxonName.filter({ ...params, ancestrify: true, per: 2000 }).then(
        ({ body }) => {
          const tree = buildTree(body)
          this.taxonNames = body

          this.treeLeft = tree
          this.treeRight = structuredClone(tree)
        }
      )
    },

    setCurrentDraggedItem(taxon) {
      this.currentDragged = taxon
    }
  }
})
