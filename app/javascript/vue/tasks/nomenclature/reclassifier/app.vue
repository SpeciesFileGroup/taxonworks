<template>
  <div class="flex flex-separate middle">
    <h1>Taxon name reclassifier</h1>
    <ul class="context-menu">
      <li>
        <a :href="RouteNames.FilterNomenclature">Filter taxon name</a>
      </li>
    </ul>
  </div>
  <div
    class="horizontal-left-content gap-medium align-start"
    v-help="
      'You can drag and drop nodes between the two taxonomy trees to reorganize them. To select multiple nodes, hold the <b>Ctrl</b> key and click on each node you want to include.'
    "
  >
    <PanelTree
      class="full_width"
      v-model="storeLeft.tree"
      :target="storeRight.tree"
      :group="{
        name: 'tree-1',
        put: handlePut
      }"
      @sync="() => (storeLeft.tree = cloneTree(storeRight.tree))"
      @load="
        (id) =>
          loadTree(
            { taxon_name_id: [id] },
            { storeA: storeLeft, storeB: storeRight }
          )
      "
    />
    <PanelTree
      class="full_width"
      v-model="storeRight.tree"
      :target="storeLeft.tree"
      :group="{
        name: 'tree-2',
        put: handlePut
      }"
      @sync="() => (storeRight.tree = cloneTree(storeLeft.tree))"
      @load="
        (id) =>
          loadTree(
            { taxon_name_id: [id] },
            { storeA: storeRight, storeB: storeLeft }
          )
      "
    />
  </div>
</template>

<script setup>
import { onBeforeMount, toRaw } from 'vue'
import { useQueryParam } from '@/tasks/data_attributes/field_synchronize/composables'
import { findNodeById } from './utils'
import { RouteNames } from '@/routes/routes.js'
import { vHelp } from '@/directives/help.js'
import useStore from './store/store.js'
import PanelTree from './components/Tree/PanelTree.vue'

defineOptions({
  name: 'TaxonNameReclassifierApp'
})

const { queryParam, queryValue } = useQueryParam()
const storeLeft = useStore('treeLeft')()
const storeRight = useStore('treeRight')()

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

  const draggedNode =
    findNodeById(storeLeft.tree, dragId) ||
    findNodeById(storeRight.tree, dragId)
  const targetNode =
    findNodeById(storeLeft.tree, toParentId) ||
    findNodeById(storeRight.tree, toParentId)

  return (
    toTree !== fromTree &&
    toParentId !== fromParent &&
    dragId !== toParentId &&
    !isDescendant(draggedNode, targetNode.id)
  )
}

async function loadTree(parameters, { storeA, storeB }) {
  try {
    const tree = await storeA.loadTree(parameters)

    if (!storeB.tree.length) {
      storeB.setTree(cloneTree(tree))
    }
  } catch {}
}

function cloneTree(tree) {
  return structuredClone(JSON.parse(JSON.stringify(tree)))
}

onBeforeMount(async () => {
  try {
    if (queryParam.value === 'taxon_name_query') {
      loadTree(queryValue.value, { storeA: storeLeft, storeB: storeRight })
    }
  } catch {}
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
