<template>
  <div class="panel content">
    <div class="grid-header">
      <h3>
        Building grid
        <span
          v-if="zoomStack.length"
          class="building-name"
          >{{ zoomStack[0].name }}</span
        >
      </h3>
      <VBtn
        v-if="buildingId"
        color="primary"
        medium
        :href="visualizeHref"
        target="_blank"
        class="flex-row middle"
      >
        Visualize
      </VBtn>
    </div>

    <!-- Breadcrumb trail — only visible when zoomed into a child -->
    <div class="breadcrumb-row">
      <template v-if="zoomStack.length > 1">
        <span
          v-for="(crumb, i) in zoomStack"
          :key="crumb.id"
          class="breadcrumb-item"
        >
          <span
            v-if="i > 0"
            class="breadcrumb-sep"
            >&rsaquo;</span
          >
          <span
            :class="[
              'breadcrumb-link',
              { 'breadcrumb-current': i === zoomStack.length - 1 }
            ]"
            @click="zoomTo(i)"
            >{{ crumb.name }}</span
          >
        </span>
      </template>
      <span
        v-else
        class="breadcrumb-empty"
        >&nbsp;</span
      >
    </div>

    <div
      v-if="!buildingId"
      class="suble"
    >
      Select or create a building to see the grid.
    </div>
    <VSpinner v-else-if="loading" />
    <template v-else>
      <GridResizeControls
        :container="currentContainer"
        :saving="saving"
        :error="expandError"
        @resize="onResize"
      />

      <div
        v-if="!currentContainer?.size_x || !currentContainer?.size_y"
        class="subtle"
      >
        Container has no x/y dimensions defined.
      </div>
      <VSpinner v-else-if="moving" />
      <template v-else>
        <span
          v-if="moveError"
          class="feedback-warning"
          >{{ moveError }}</span
        >
        <SvgGrid
          :cols="currentContainer.size_x"
          :rows="currentContainer.size_y"
          :cells="placedCells"
          @cell-click="onCellClick"
          @cell-dblclick="onCellDblclick"
          @move="onMove"
        />
      </template>
    </template>

    <CellModal
      v-if="modal.visible"
      :cell="{ col: modal.col, row: modal.row }"
      :occupant="modal.occupant"
      :unplaced-children="unplacedChildren"
      :place-error="placeError"
      @close="closeModal"
      @place="placeChild"
      @unplace="unplaceOccupant"
      @autocomplete-pick="placeFromAutocomplete"
      @occupant-updated="onOccupantUpdated"
    />
  </div>
</template>

<script setup>
import { ref, computed, toRef } from 'vue'
import SvgGrid from './SvgGrid.vue'
import CellModal from './CellModal.vue'
import GridResizeControls from './GridResizeControls.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import { Container, ContainerItem } from '@/routes/endpoints'
import { useZoomStack } from '../composables/useZoomStack'
import { usePlacement } from '../composables/usePlacement'

const props = defineProps({
  buildingId: {
    type: Number,
    default: null
  }
})

const emit = defineEmits(['add-container'])

const visualizeHref = computed(() =>
  props.buildingId
    ? `/tasks/containers/collection_visualization?container_id=${props.buildingId}`
    : '/tasks/containers/collection_visualization'
)

const {
  zoomStack,
  children,
  loading,
  currentContainer,
  placedCells,
  unplacedChildren,
  loadChildren,
  drillInto,
  zoomTo,
  navigateTo,
  patchCurrentSize,
  renameInStack
} = useZoomStack(toRef(props, 'buildingId'))

const { placeError, place, unplace, reset: resetPlaceError } = usePlacement()

const moving = ref(false)
const saving = ref(false)
const expandError = ref('')
const moveError = ref('')
const modal = ref({ visible: false, col: null, row: null, occupant: null })

// ── Cell modal ────────────────────────────────────────────────────────────────

function onCellClick({ col, row }) {
  const occupant =
    children.value.find(
      (c) => c.disposition_x === col && c.disposition_y === row
    ) || null
  resetPlaceError()
  moveError.value = ''
  modal.value = { visible: true, col, row, occupant }
}

async function onCellDblclick({ col, row }) {
  const child = children.value.find(
    (c) => c.disposition_x === col && c.disposition_y === row
  )
  await drillInto(child)
}

function closeModal() {
  modal.value = { visible: false, col: null, row: null, occupant: null }
}

function refreshModalOccupant() {
  if (!modal.value.visible) return
  const { col, row } = modal.value
  const occupant =
    children.value.find(
      (c) => c.disposition_x === col && c.disposition_y === row
    ) || null
  modal.value = { ...modal.value, occupant }
}

async function placeChild(item) {
  const ok = await place(
    item.container_item_id,
    modal.value.col,
    modal.value.row
  )
  if (ok) {
    await loadChildren(currentContainer.value.id)
    refreshModalOccupant()
  }
}

async function unplaceOccupant(occupant) {
  const ok = await unplace(occupant.container_item_id)
  if (ok) {
    await loadChildren(currentContainer.value.id)
    refreshModalOccupant()
  }
}

async function placeFromAutocomplete({ container, cell }) {
  const child = children.value.find((c) => c.id === container.id)
  if (child) {
    const ok = await place(child.container_item_id, cell.col, cell.row)
    if (ok) {
      await loadChildren(currentContainer.value.id)
      refreshModalOccupant()
    }
  } else {
    emit('add-container', { container, col: cell.col, row: cell.row })
    closeModal()
  }
}

function onOccupantUpdated({ field, body }) {
  if (field === 'name') {
    renameInStack(body.id, body.name)
    if (modal.value.occupant?.id === body.id) {
      modal.value = {
        ...modal.value,
        occupant: { ...modal.value.occupant, name: body.name }
      }
    }
  }
}

// ── Move (drag-drop) ──────────────────────────────────────────────────────────

async function onMove(moves) {
  moving.value = true
  moveError.value = ''

  // Determine the shared direction of travel so we can sort moves to clear
  // destination cells before source cells arrive (e.g. moving a column up:
  // process the topmost item first so each destination is free in turn).
  const deltaRow = moves.length ? moves[0].to.row - moves[0].from.row : 0
  const deltaCol = moves.length ? moves[0].to.col - moves[0].from.col : 0

  const sorted = [...moves].sort((a, b) => {
    if (deltaRow !== 0)
      return deltaRow < 0 ? a.to.row - b.to.row : b.to.row - a.to.row
    if (deltaCol !== 0)
      return deltaCol < 0 ? a.to.col - b.to.col : b.to.col - a.to.col
    return 0
  })

  // First pass — sequential so each PATCH lands before the next departs
  const failed = []
  for (const { from, to } of sorted) {
    const child = children.value.find(
      (c) => c.disposition_x === from.col && c.disposition_y === from.row
    )
    if (!child) continue
    const { body } = await ContainerItem.update(child.container_item_id, {
      container_item: { disposition_x: to.col, disposition_y: to.row }
    })
    if (!body?.id) failed.push({ child, to })
  }

  // Second pass — retry anything that bounced the first time
  const stillFailed = []
  for (const { child, to } of failed) {
    const { body } = await ContainerItem.update(child.container_item_id, {
      container_item: { disposition_x: to.col, disposition_y: to.row }
    })
    if (!body?.id) stillFailed.push(child)
  }

  await loadChildren(currentContainer.value.id)
  moving.value = false

  if (stillFailed.length) {
    moveError.value = 'Try a simpler move.'
  }
}

// ── Resize ────────────────────────────────────────────────────────────────────

async function onResize(attrs) {
  saving.value = true
  expandError.value = ''

  let body
  try {
    ;({ body } = await Container.update(currentContainer.value.id, {
      container: attrs
    }))
  } catch (error) {
    saving.value = false
    const errors = error?.response?.body
    const message = errors
      ? Object.values(errors).flat().join(', ')
      : 'Could not update dimensions.'
    expandError.value = message.includes('Resize would impact')
      ? 'Resize would impact placed Containers.'
      : message
    return
  }

  saving.value = false
  patchCurrentSize({ size_x: body.size_x, size_y: body.size_y })
}

defineExpose({
  reload: () =>
    currentContainer.value && loadChildren(currentContainer.value.id),
  navigateTo
})
</script>

<style scoped lang="scss">
@use 'sass:map';
@use '../../../../assets/styles/variables/_palette.scss' as *;

.building-name {
  font-weight: normal;
  font-size: 0.85em;
  color: #555;
  margin-left: 0.5em;
}

.grid-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 0.25em;
}

.grid-header h3 {
  margin: 0;
}

.breadcrumb-row {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 0.25em;
  min-height: 1.4em;
  margin-bottom: 0.5em;
  font-size: 0.88em;
  border-bottom: 1px solid var(--border-color);
  padding-bottom: 0.35em;
}

.breadcrumb-empty {
  display: block;
}

.breadcrumb-sep {
  color: #bbb;
}

.breadcrumb-link {
  cursor: pointer;
  color: #1976d2;
}

.breadcrumb-link:hover {
  text-decoration: underline;
}

.breadcrumb-current {
  color: #333;
  font-weight: 600;
  cursor: default;
  pointer-events: none;
}

.breadcrumb-current:hover {
  text-decoration: none;
}
</style>
