<template>
  <h1>Taxon name reclassifier</h1>
  <div class="horizontal-left-content gap-medium align-start">
    <PanelTree
      class="full_width"
      :group="{
        name: 'tree-1',
        put: handlePut
      }"
      v-model="store.tree"
    />
    <PanelTree
      class="full_width"
      :group="{
        name: 'tree-2',
        put: handlePut
      }"
      v-model="store.tree"
    />
  </div>
</template>

<script setup>
import { onBeforeMount } from 'vue'
import { useQueryParam } from '@/tasks/data_attributes/field_synchronize/composables'
import useStore from './store/store.js'
import PanelTree from './components/Tree/PanelTree.vue'

defineOptions({
  name: 'TaxonNameReclassifierApp'
})

const { queryParam, queryValue } = useQueryParam()
const store = useStore()

function findNodeById(treeArray, id) {
  for (const node of treeArray) {
    if (node.id == id) return node
    if (node.children && node.children.length) {
      const found = findNodeById(node.children, id)
      if (found) return found
    }
  }
  return null
}

function isDescendant(node, targetNodeId) {
  if (!node.children || node.children.length === 0) return false

  for (const child of node.children) {
    if (child.id === targetNodeId) return true
    if (isDescendant(child, targetNodeId)) return true
  }

  return false
}

function handlePut(to, from, dragEl) {
  const toParentId = to.el.dataset.parentId
  const toTree = to.el.dataset.tree
  const fromParent = from.el.dataset.parentId
  const fromTree = from.el.dataset.tree
  const dragId = dragEl.dataset.taxonId

  const draggedNode = findNodeById(store.tree, dragId)
  const targetNode = findNodeById(store.tree, toParentId)

  return (
    toTree !== fromTree &&
    toParentId !== fromParent &&
    dragId !== toParentId &&
    !isDescendant(draggedNode, targetNode.id)
  )
}

onBeforeMount(() => {
  if (queryParam.value === 'taxon_name_query') {
    store.loadTree(queryValue.value)
  }
})
</script>

<style lang="scss">
#reclassifier_task {
  .taxonomy-tree {
    ul {
      margin-left: 12px;
    }

    li {
      padding-left: 6px;
    }
  }
}
</style>
