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
      ref="panelLeft"
      class="full_width"
      v-model="storeLeft.tree"
      :target="storeRight.tree"
      :group="{
        name: 'tree-1',
        put: handlePut
      }"
      @focus="(taxon) => storeLeft.setTree([taxon])"
      @sync="() => (storeLeft.tree = cloneTree(storeRight.tree))"
      @load="
        (id) =>
          loadTree(
            { taxon_name_id: [id] },
            { storeA: storeLeft, storeB: storeRight }
          )
      "
      @align="
        (taxon) => {
          cloneAndAlign({
            compRef: panelRightRef,
            taxon,
            storeA: storeLeft,
            storeB: storeRight
          })
        }
      "
    />
    <PanelTree
      ref="panelRight"
      class="full_width"
      v-model="storeRight.tree"
      :target="storeLeft.tree"
      :group="{
        name: 'tree-2',
        put: handlePut
      }"
      @focus="(taxon) => storeRight.setTree([taxon])"
      @sync="() => (storeRight.tree = cloneTree(storeLeft.tree))"
      @load="
        (id) =>
          loadTree(
            { taxon_name_id: [id] },
            { storeA: storeRight, storeB: storeLeft }
          )
      "
      @align="
        (taxon) => {
          cloneAndAlign({
            compRef: panelLeftRef,
            taxon,
            storeA: storeRight,
            storeB: storeLeft
          })
        }
      "
    />
  </div>
</template>

<script setup>
import { nextTick, onBeforeMount, toRaw, useTemplateRef } from 'vue'
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
const panelLeftRef = useTemplateRef('panelLeft')
const panelRightRef = useTemplateRef('panelRight')

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

function scrollToNode(element) {
  element.scrollIntoView({ behavior: 'smooth', block: 'center' })
  element.classList.add('highlight-effect')
  element.addEventListener(
    'animationend',
    () => {
      element.classList.remove('highlight-effect')
    },
    { once: true }
  )
}

async function cloneAndAlign({ compRef, taxon, storeA, storeB }) {
  storeB.setTree(cloneTree(storeA.tree))

  nextTick(() => {
    const element = compRef.$el.querySelector(
      `[data-taxon-id="${taxon.id}"] .list-reclassifer-taxon-item`
    )

    if (element) {
      scrollToNode(element)
    }
  })
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

  .highlight-effect {
    animation: highlight 1.5s ease;
  }

  @keyframes highlight {
    0% {
      background-color: transparent;
    }
    50% {
      background-color: var(--color-warning);
    }
    100% {
      background-color: transparent;
    }
  }
}
</style>
