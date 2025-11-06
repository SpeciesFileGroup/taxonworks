<template>
  <li
    :class="[
      'cursor-grab',
      isMouseover &&
        taxon.id !== interactionStore.currentDragged.taxon.parentId &&
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
      @dblclick="openBrowse"
      @contextmenu="handleContextMenu"
      @click.prevent="() => addToSelected(taxon)"
      @mouseup="
        () => {
          if (!interactionStore.isDragging && !isKeyPressed('Control')) {
            interactionStore.resetSelected()
          }
        }
      "
      @mousedown="
        (event) => {
          if (event.button === 1) {
            openBrowse('_blank')
          }
        }
      "
    />

    <ContextMenu
      ref="contextMenu"
      class="flex-col"
    >
      <div
        class="context-menu-header padding-small"
        v-html="taxon.name"
      />

      <a
        v-for="task in TASKS"
        :key="task.url"
        class="vue-context-menu-item"
        :href="`${task.url}?taxon_name_id=${taxon.id}`"
        v-text="task.label"
      />

      <div
        class="vue-context-menu-item"
        @click="() => emit('focus', taxon)"
      >
        Focus
      </div>
      <div
        class="vue-context-menu-item"
        @click="() => emit('align', taxon)"
      >
        Clone tree and align
      </div>
    </ContextMenu>

    <VDraggable
      v-show="(!taxon.isLoaded || taxon.isExpanded) && taxon.children"
      :class="[
        'taxonomy-tree',
        interactionStore.currentDragged?.parent?.id === taxon.id &&
          'current-group'
      ]"
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
      @start="() => (interactionStore.isDragging = true)"
      @end="
        () => {
          interactionStore.isDragging = false
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
          @align="(e) => emit('align', e)"
          @focus="(e) => emit('focus', e)"
        />
      </template>
    </VDraggable>

    <ul
      class="taxonomy-tree"
      v-if="
        interactionStore.isDragging &&
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
      legend="Moving taxon... This may take longer if it has many children."
    />
  </li>
</template>

<script setup>
import { computed, ref, onMounted, onBeforeUnmount, useTemplateRef } from 'vue'
import { TaxonName } from '@/routes/endpoints'
import { findNodeById, removeNode, makeTaxonNode } from '../../utils'
import { usePressedKey } from '@/composables/usePressedKey'
import { makeBrowseUrl } from '@/helpers'
import { TAXON_NAME } from '@/constants'
import { removeFromArray } from '@/helpers'
import { RouteNames } from '@/routes/routes'
import TreeNode from './TreeNode.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VDraggable from 'vuedraggable'
import VSpinner from '@/components/ui/VSpinner.vue'
import ContextMenu from '@/components/ui/Context/ContextMenu.vue'
import useInteractionStore from '../../store/interaction.js'

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

const emit = defineEmits(['focus', 'align'])

const TASKS = [
  {
    label: 'Browse taxon name',
    url: RouteNames.BrowseNomenclature
  },
  {
    label: 'New taxon name',
    url: RouteNames.NewTaxonName
  }
]

const isUpdating = ref(false)
const isLoading = ref(false)
const interactionStore = useInteractionStore()
const isMouseover = ref(false)
const contextMenuRef = useTemplateRef('contextMenu')

const { isKeyPressed } = usePressedKey()

const selectedItems = computed(() =>
  interactionStore.getSelectedItemsByGroup(
    interactionStore.currentDragged?.parent?.id
  )
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

function openBrowse(target = '_self') {
  window.open(makeBrowseUrl({ id: props.taxon.id, type: TAXON_NAME }), target)
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
    interactionStore.addSelected(item, props.taxon.parentId)
  } else {
    //interactionStore.setSelectedGroup([item], props.taxon.parentId)
  }
}

const isSelected = computed(() =>
  interactionStore.selected[props.taxon.parentId]?.some(
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
  interactionStore.setCurrentDraggedTaxon({
    parent: props.taxon,
    taxon: props.taxon.children[e.oldIndex],
    index: e.oldIndex
  })
}

function reasignNode(parentId, index) {
  const targetParent = findNodeById(props.target, parentId)

  if (targetParent) {
    targetParent.children.splice(index, 0, {
      ...interactionStore.currentDragged.taxon,
      parentId: parentId
    })
  }
}

function moveTaxon({ taxon, parentId, newIndex }) {
  const payload = {
    taxon_name: { parent_id: parentId }
  }

  const request = TaxonName.update(taxon.id, payload)
  const children = interactionStore.currentDragged.parent.children

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
        children.splice(interactionStore.currentDragged.index, 0, taxon)
      }
    })

  return request
}

function handleContextMenu(e) {
  e.preventDefault()

  if (e.ctrlKey) {
    addToSelected(props.taxon)
  } else {
    contextMenuRef.value.openContextMenu(e)
  }
}

function handleAdd(e) {
  const { newIndex } = e
  const movedTaxon = props.taxon.children[newIndex]
  const items = [movedTaxon, ...selectedItems.value]

  if (!isDroppedInside(e)) {
    props.taxon.children.splice(newIndex, 1)

    interactionStore.currentDragged.parent.children.splice(
      interactionStore.currentDragged.index,
      0,
      interactionStore.currentDragged.taxon
    )

    return
  }

  isUpdating.value = true

  const promises = items.map((taxon) =>
    moveTaxon({ taxon, parentId: props.taxon.id, newIndex })
  )

  Promise.all(promises)
    .then(() => {
      interactionStore.resetSelected()
    })
    .catch(() => {})
    .finally(() => {
      isUpdating.value = false
    })
}
</script>

<style scoped>
.list-reclassifer-taxon-item:hover,
.selected {
  background-color: var(--color-data);
  color: #ffffff;
}

.list-reclassifer-taxon-item {
  border-radius: 0.5rem;
  padding: 2px 4px;
}

.sortable-ghost {
  .list-reclassifer-taxon-item {
    color: #ffffff;
    background-color: var(--color-update);
  }
}

.ghost-list {
  .selected {
    color: #ffffff;
    background-color: var(--color-update);
  }
}

.current-group > .sortable-ghost > .list-reclassifer-taxon-item {
  color: #ffffff;
  background-color: var(--color-primary);
}

.taxonomy-tree-ghost-hover {
  border: 2px dashed var(--color-update);
  border-left: 2px dashed var(--color-update) !important;
}

:deep(.taxonomy-tree) {
  ul {
    padding: 4px 0;
  }
}

.vue-context-menu {
  z-index: 2;
  .context-menu-header {
    background-color: var(--bg-color);
    border-bottom: 1px solid var(--border-color);
  }
  .vue-context-menu-item {
    cursor: pointer;
    border-bottom: 1px solid var(--border-color);
    padding: 1em;
  }
}
</style>
