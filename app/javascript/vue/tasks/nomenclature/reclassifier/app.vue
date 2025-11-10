<template>
  <div class="flex flex-separate middle">
    <h1>Taxon name reclassifier</h1>
    <ul class="context-menu">
      <li>
        <a :href="RouteNames.FilterNomenclature">Filter taxon name</a>
      </li>
      <li>
        <VBtn
          color="primary"
          circle
          @click="reset"
        >
          <VIcon
            name="reset"
            x-small
          />
        </VBtn>
      </li>
    </ul>
  </div>
  <div
    class="horizontal-left-content gap-medium align-start position-relative"
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
    <UnifyWindow />
    <VSpinner
      v-if="isLoading"
      full-screen
    />
  </div>
</template>

<script setup>
import { nextTick, onBeforeMount, ref, useTemplateRef } from 'vue'
import { useQueryParam } from '@/tasks/data_attributes/field_synchronize/composables'
import { findNodeById } from './utils'
import { RouteNames } from '@/routes/routes.js'
import { vHelp } from '@/directives/help.js'
import { QUERY_PARAM } from '@/components/radials/filter/constants/queryParam'
import { TAXON_NAME } from '@/constants'
import { URLParamsToJSON } from '@/helpers'
import useStore from './store/store.js'
import PanelTree from './components/Tree/PanelTree.vue'
import UnifyWindow from './components/UnifyWindow.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

defineOptions({
  name: 'TaxonNameReclassifierApp'
})

const { queryParam, queryValue } = useQueryParam()
const storeLeft = useStore('treeLeft')()
const storeRight = useStore('treeRight')()
const panelLeftRef = useTemplateRef('panelLeft')
const panelRightRef = useTemplateRef('panelRight')
const isLoading = ref(false)

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
    isLoading.value = true
    const tree = await storeA.loadTree(parameters)

    if (!storeB.tree.length) {
      storeB.setTree(cloneTree(tree))
    }
  } catch {
  } finally {
    isLoading.value = false
  }
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

function reset() {
  storeLeft.$reset()
  storeRight.$reset()

  loadFromParameters()
}

function loadFromParameters() {
  const { taxon_name_id } = URLParamsToJSON(window.location.href)
  try {
    if (queryParam.value === QUERY_PARAM[TAXON_NAME]) {
      loadTree(queryValue.value, { storeA: storeLeft, storeB: storeRight })
    } else if (taxon_name_id) {
      storeLeft.loadTree({ taxon_name_id })
    } else {
      loadTree(
        { name: 'Root', name_exact: true },
        { storeA: storeLeft, storeB: storeRight }
      )
    }
  } catch {}
}

onBeforeMount(async () => {
  TW.workbench.keyboard.createLegend(
    `Ctrl+Left click`,
    'Select multiple nodes',
    'Taxon name reclassifier'
  )

  loadFromParameters()
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
    animation: highlight 2.5s ease;
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
