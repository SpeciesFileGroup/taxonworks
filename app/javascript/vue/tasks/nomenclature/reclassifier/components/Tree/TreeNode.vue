<template>
  <li
    :class="[
      'cursor-grab',
      isMouseover &&
        taxon.id !== store.currentDragged.taxon.parentId &&
        'taxonomy-tree-ghost-hover'
    ]"
  >
    <VBtn
      v-if="!taxon.leaf"
      circle
      small
      color="primary"
      :disabled="isLoading"
      @click="toggle"
    >
      <span v-if="taxon.isLoaded && taxon.isExpanded">-</span>
      <span v-else>+</span>
    </VBtn>

    <span
      :class="['list-reclassifer-taxon-item', isSelected && 'selected']"
      v-html="taxon.name"
      @click.prevent="() => addToSelected(taxon)"
    />

    <template v-if="(!taxon.isLoaded || taxon.isExpanded) && taxon.children">
      <VDraggable
        class="taxonomy-tree"
        ref="rootEl"
        item-key="id"
        :group="group"
        v-model="taxon.children"
        tag="ul"
        :sort="false"
        :data-parent-id="taxon.id"
        :data-tree="group.name"
        handle=".list-reclassifer-taxon-item"
        :swapThreshold="0.65"
        invertSwap
        forceFallback
        fallbackOnBody
        @add="handleAdd"
        @choose="handleChoose"
        @start="() => (store.isDragging = true)"
        @end="
          () => {
            store.isDragging = false
            onDragEndCleanup()
          }
        "
      >
        <template #item="{ element }">
          <TreeNode
            :taxon="element"
            :group="group"
            :data-parent-id="taxon.id"
            :data-taxon-id="element.id"
            :only-valid="onlyValid"
            :tree="tree"
            :target="target"
          />
        </template>
      </VDraggable>
    </template>
    <ul
      class="taxonomy-tree"
      v-if="
        store.isDragging &&
        isMouseover &&
        selectedItems.every((t) => t.parentId !== props.taxon.id)
      "
    >
      <li
        v-for="item in selectedItems"
        :key="item.id"
        class="ghost-list"
      >
        <span
          class="list-reclassifer-taxon-item selected"
          v-html="item.name"
        />
      </li>
    </ul>
    <VSpinner
      v-if="isUpdating"
      full-screen
      legend="Moving taxon..."
    />
  </li>
</template>

<script setup>
import { computed, ref, onMounted, onBeforeUnmount } from 'vue'
import { TaxonName } from '@/routes/endpoints'
import { findNodeById, removeNode, makeTaxonNode } from '../../utils'
import { usePressedKey } from '@/composables/usePressedKey'
import TreeNode from './TreeNode.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VDraggable from 'vuedraggable'
import useStore from '../../store/store.js'
import { removeFromArray } from '@/helpers'
import VSpinner from '@/components/ui/VSpinner.vue'

const GHOST_SELECTOR = '.sortable-ghost'

const props = defineProps({
  taxon: {
    type: Object,
    required: true
  },

  group: {
    type: Object,
    required: true
  },

  onlyValid: {
    type: Boolean,
    default: false
  },

  tree: {
    type: Object,
    required: true
  },

  target: {
    type: Array,
    required: true
  }
})

const isUpdating = ref(false)
const isLoading = ref(false)
const store = useStore()
const isMouseover = ref(false)

const { isKeyPressed } = usePressedKey()

const selectedItems = computed(() =>
  store.selected[store.currentDragged?.parent?.id]
    ? store.selected[store.currentDragged.parent.id].filter(
        (item) => item.id !== store.currentDragged.taxon.id
      )
    : []
)

const rootEl = ref(null)

let observer = null

function updateIsMouseoverFromGhost(el) {
  const ghost = document.querySelector(GHOST_SELECTOR)
  if (!ghost) {
    if (isMouseover.value) isMouseover.value = false
    return
  }

  const ghostList = ghost.closest('.taxonomy-tree')

  isMouseover.value = ghostList === el
}

function setupObserverForRoot(el) {
  if (!el) return

  observer = new MutationObserver(() => {
    updateIsMouseoverFromGhost(el)
  })

  observer.observe(document.body, { childList: true, subtree: true })
}

onMounted(() => setupObserverForRoot(rootEl.value.$el))
onBeforeUnmount(() => {
  observer?.disconnect()
})

function onDragEndCleanup() {
  isMouseover.value = false
}

function addToSelected(item) {
  if (isKeyPressed('Control')) {
    const selectedItems = store.selected[props.taxon.parentId]

    if (selectedItems) {
      const index = selectedItems.findIndex((t) => t.id === item.id)

      if (index > -1) {
        selectedItems.splice(index, 1)
      } else {
        selectedItems.push(item)
      }
    } else {
      store.selected[props.taxon.parentId] = [item]
    }
  }
}

const isSelected = computed(() =>
  store.selected[props.taxon.parentId]?.some(
    (item) => item.id === props.taxon.id
  )
)

function toggle() {
  if (!props.taxon.isLoaded) {
    expandNode(props.taxon.id)
  }

  props.taxon.isExpanded = !props.taxon.isExpanded
}

function isDroppedInside(evt) {
  const mouseX = evt.originalEvent.clientX
  const mouseY = evt.originalEvent.clientY

  const rect = evt.to.getBoundingClientRect()
  const droppedInside =
    mouseX >= rect.left &&
    mouseX <= rect.right &&
    mouseY >= rect.top &&
    mouseY <= rect.bottom

  return droppedInside
}

function expandNode(taxonId) {
  isLoading.value = true
  TaxonName.taxonomy(taxonId, {
    ancestors: false,
    count: false
  })
    .then(({ body }) => {
      const children = body.descendants.map((c) => makeTaxonNode(c))

      children.forEach((item, index) => {
        const current = props.taxon.children.find((c) => c.id === item.id)

        if (current) {
          children[index] = current
        }
      })

      props.taxon.isExpanded = true
      props.taxon.isLoaded = true
      props.taxon.children = children
    })
    .finally(() => {
      isLoading.value = false
    })
}

function handleChoose(e) {
  store.setCurrentDraggedTaxon({
    parent: props.taxon,
    taxon: props.taxon.children[e.oldIndex],
    index: e.oldIndex
  })
}

function reasignNode(parentId, index) {
  const targetParent = findNodeById(props.target, parentId)

  if (targetParent) {
    targetParent.children.splice(index, 0, {
      ...store.currentDragged.taxon,
      parentId: parentId
    })
  }
}

function moveTaxon({ taxon, parentId, newIndex }) {
  const payload = {
    taxon_name: { parent_id: parentId }
  }

  const request = TaxonName.update(taxon.id, payload)
  const children = store.currentDragged.parent.children

  request
    .then(({ body }) => {
      const newName = [body.cached_html, body.cached_author_year].join(' ')

      removeNode(props.tree, {
        id: taxon.id,
        parentId: taxon.parentId
      })

      Object.assign(taxon, {
        parentId: body.parent_id,
        name: newName
      })

      reasignNode(taxon.parentId, newIndex)

      if (props.taxon.children.every((c) => c.id !== taxon.id)) {
        props.taxon.children.splice(newIndex, 0, taxon)

        removeFromArray(children, taxon)
      }

      TW.workbench.alert.create(`${newName} was reclassified to successfully`)
    })
    .catch(() => {
      props.taxon.children.splice(newIndex, 1)

      if (children.every((c) => c.id !== taxon.id)) {
        children.splice(store.currentDragged.index, 0, taxon)
      }
    })

  return request
}

function handleAdd(e) {
  const { newIndex } = e
  const movedTaxon = props.taxon.children[newIndex]
  const items = [movedTaxon, ...selectedItems.value]

  if (!isDroppedInside(e)) {
    props.taxon.children.splice(newIndex, 1)

    store.currentDragged.parent.children.splice(
      store.currentDragged.index,
      0,
      store.currentDragged.taxon
    )

    return
  }

  isUpdating.value = true

  const promises = items.map((taxon) =>
    moveTaxon({ taxon, parentId: props.taxon.id, newIndex })
  )

  Promise.all(promises)
    .then(() => {
      store.selected[store.currentDragged.parent.id] = []
    })
    .catch(() => {})
    .finally(() => {
      isUpdating.value = false
    })
}
</script>

<style scoped>
.list-reclassifer-taxon-item {
  border: 2px dashed transparent;
}

.list-reclassifer-taxon-item:hover,
.selected {
  border-color: var(--color-primary);
}

.sortable-ghost {
  .list-reclassifer-taxon-item:hover {
    border: 2px dashed transparent;
  }
  .list-reclassifer-taxon-item {
    border: 2px dashed var(--color-update);
  }
}

.ghost-list {
  .selected {
    border-color: var(--color-update);
  }
}

.taxonomy-tree-ghost-hover {
  border: 2px dashed var(--color-update);
  border-left: 2px dashed var(--color-update) !important;
}

.taxonomy-tree {
  ul {
    padding: 4px 0;
  }
}
</style>
