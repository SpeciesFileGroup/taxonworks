<template>
  <div class="building-grid-panel panel content">
    <div class="grid-header">
      <h3>
        Building grid
        <span
          v-if="zoomStack.length"
          class="building-name"
        >{{ zoomStack[0].name }}</span>
      </h3>
      <VBtn
        v-if="buildingId"
        color="primary"
        medium
        :href="visualizeHref"
        target="_blank"
        class="viz-task-link"
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
          >&rsaquo;</span>
          <span
            :class="['breadcrumb-link', { 'breadcrumb-current': i === zoomStack.length - 1 }]"
            @click="zoomTo(i)"
          >{{ crumb.name }}</span>
        </span>
      </template>
      <span
        v-else
        class="breadcrumb-empty"
      >&nbsp;</span>
    </div>

    <div
      v-if="!buildingId"
      class="muted"
    >
      Select or create a building to see the grid.
    </div>
    <VSpinner v-else-if="loading" />
    <template v-else>

      <!-- Expand controls (apply to current zoom target) -->
      <div class="expand-controls horizontal-left-content gap-small flex-wrap">
        <label class="horizontal-left-content gap-xsmall middle">
          <input
            v-model.number="expandRowsBy"
            type="number"
            min="1"
            class="normal-input small-input"
          />
          <VBtn
            color="default"
            medium
            :disabled="!expandRowsBy || saving"
            @click="expandRows"
          >
            + rows
          </VBtn>
        </label>

        <label class="horizontal-left-content gap-xsmall middle">
          <input
            v-model.number="expandColsBy"
            type="number"
            min="1"
            class="normal-input small-input"
          />
          <VBtn
            color="default"
            medium
            :disabled="!expandColsBy || saving"
            @click="expandCols"
          >
            + columns
          </VBtn>
        </label>

        <span
          v-if="expandError"
          class="feedback-warning"
        >{{ expandError }}</span>
      </div>

      <div
        v-if="!currentContainer?.size_x || !currentContainer?.size_y"
        class="muted"
      >
        Container has no x/y dimensions defined.
      </div>
      <VSpinner v-else-if="moving" />
      <template v-else>
        <span
          v-if="moveError"
          class="feedback-warning"
        >{{ moveError }}</span>
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

    <!-- Cell modal -->
    <VModal
      v-if="modal.visible"
      :container-style="{ width: modal.occupant ? '860px' : '520px' }"
      @close="closeModal"
    >
      <template #header>
        <h3>Cell ({{ modal.col }}, {{ modal.row }})</h3>
      </template>
      <template #body>
        <div :class="['modal-body-inner', { 'modal-two-col': modal.occupant }]">

          <!-- Left column: placement -->
          <div class="modal-col-placement">

            <!-- Occupant -->
            <div
              v-if="modal.occupant"
              class="cell-occupant"
            >
              <strong>Current occupant:</strong> {{ modal.occupant.name }}
              <span class="feedback feedback-thin feedback-secondary">{{ modal.occupant.type }}</span>
              <VBtn
                color="default"
                circle
                @click="unplaceOccupant"
              >
                <VIcon
                  name="undo"
                  x-small
                  class="icon-unplace"
                />
              </VBtn>
            </div>

            <!-- Unplaced children list -->
            <div v-if="unplacedChildren.length">
              <h4>Unplaced children</h4>
              <ul class="unplaced-list">
                <li
                  v-for="item in unplacedChildren"
                  :key="item.container_item_id"
                  class="unplaced-item"
                  @click="placeChild(item)"
                >
                  <span class="container-type-badge">{{ item.type.split('::').slice(1).join('::') }}</span>
                  {{ item.name }}
                </li>
              </ul>
            </div>
            <div
              v-else
              class="muted"
            >
              No unplaced children.
            </div>

            <hr class="modal-divider" />

            <!-- Autocomplete -->
            <h4>Find and place a container</h4>
            <div class="horizontal-left-content gap-small">
              <VAutocomplete
                url="/containers/autocomplete"
                placeholder="Find a container…"
                param="term"
                label="label"
                @get-item="placeFromAutocomplete"
              />
            </div>

            <span
              v-if="placeError"
              class="feedback-warning"
            >{{ placeError }}</span>
          </div>

          <!-- Right column: edit occupant attributes -->
          <div
            v-if="modal.occupant"
            class="modal-col-edit"
          >
            <h4>Edit</h4>

            <label class="edit-field">
              Name
              <input
                v-model="editForm.name"
                type="text"
                class="normal-input full-width-input"
                @blur="saveOccupantField('name', editForm.name)"
              />
            </label>

            <div class="edit-field">
              <span class="edit-label">% empty</span>
              <div class="slider-track-row">
                <input
                  v-model.number="editForm.percentEmpty"
                  type="range"
                  min="0"
                  max="100"
                  step="1"
                  class="range-input"
                  @change="saveOccupantField('asserted_percent_empty', editForm.percentEmpty)"
                />
                <span class="slider-value">{{ editForm.percentEmpty ?? '—' }}</span>
              </div>
              <div class="slider-btn-row">
                <VBtn
                  v-for="pct in [25, 50, 100]"
                  :key="pct"
                  color="primary"
                  small
                  @click="setPercent('percentEmpty', 'asserted_percent_empty', pct)"
                >{{ pct }}</VBtn>
              </div>
            </div>

            <div class="edit-field">
              <span class="edit-label">% earmarked</span>
              <div class="slider-track-row">
                <input
                  v-model.number="editForm.percentEarmarked"
                  type="range"
                  min="0"
                  max="100"
                  step="1"
                  class="range-input"
                  @change="saveOccupantField('asserted_percent_earmarked', editForm.percentEarmarked)"
                />
                <span class="slider-value">{{ editForm.percentEarmarked ?? '—' }}</span>
              </div>
              <div class="slider-btn-row">
                <VBtn
                  v-for="pct in [25, 50, 100]"
                  :key="pct"
                  color="primary"
                  small
                  @click="setPercent('percentEarmarked', 'asserted_percent_earmarked', pct)"
                >{{ pct }}</VBtn>
              </div>
            </div>

            <label class="edit-field">
              <span class="edit-label">Print label</span>
              <textarea
                v-model="editForm.printLabel"
                rows="3"
                class="normal-input full-width-input"
                @blur="saveOccupantField('print_label', editForm.printLabel)"
              />
            </label>

            <span
              v-if="editForm.error"
              class="feedback-warning"
            >{{ editForm.error }}</span>
          </div>

        </div>
      </template>
    </VModal>
  </div>
</template>

<script setup>
import { ref, reactive, computed, watch } from 'vue'
import AjaxCall from '@/helpers/ajaxCall'
import SvgGrid from './SvgGrid.vue'
import VModal from '@/components/ui/Modal.vue'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

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

// ── State ─────────────────────────────────────────────────────────────────────

const zoomStack    = ref([])   // [{ id, name, type, size_x, size_y }, ...]
const children     = ref([])
const loading      = ref(false)
const moving       = ref(false)
const saving       = ref(false)
const expandError  = ref('')
const placeError   = ref('')
const moveError    = ref('')
const expandRowsBy = ref(1)
const expandColsBy = ref(1)
const modal        = ref({ visible: false, col: null, row: null, occupant: null })
const editForm     = reactive({ name: '', percentEmpty: null, percentEarmarked: null, printLabel: '', error: '' })

// ── Derived ───────────────────────────────────────────────────────────────────

const currentContainer = computed(() => zoomStack.value[zoomStack.value.length - 1] || null)

// ── Watchers ──────────────────────────────────────────────────────────────────

watch(() => props.buildingId, async (id) => {
  zoomStack.value = []
  children.value  = []
  if (id) await loadAll(id)
}, { immediate: true })

// ── Data loading ──────────────────────────────────────────────────────────────

async function loadAll(buildingId) {
  loading.value = true
  const { body } = await AjaxCall('get', `/containers/${buildingId}.json`)
  if (body?.id) {
    zoomStack.value = [containerSummary(body)]
    await loadChildren(buildingId)
  }
  loading.value = false
}

async function loadChildren(containerId) {
  const { body } = await AjaxCall('get', '/tasks/containers/collection_layout/children.json', {
    params: { container_id: containerId }
  })
  children.value = Array.isArray(body) ? body : []
}

function containerSummary(c) {
  return {
    id:     c.id,
    name:   c.name || c.type?.split('::').pop() || `Container ${c.id}`,
    type:   c.type,
    size_x: c.size_x,
    size_y: c.size_y
  }
}

// ── Zoom / breadcrumb ─────────────────────────────────────────────────────────

async function onCellDblclick({ col, row }) {
  const child = children.value.find(c => c.disposition_x === col && c.disposition_y === row)
  if (!child?.has_children) return

  // Fetch the child container to get its dimensions
  const { body } = await AjaxCall('get', `/containers/${child.id}.json`)
  if (!body?.id) return

  zoomStack.value = [...zoomStack.value, containerSummary(body)]
  await loadChildren(body.id)
}

async function zoomTo(index) {
  if (index === zoomStack.value.length - 1) return  // already there
  zoomStack.value = zoomStack.value.slice(0, index + 1)
  await loadChildren(zoomStack.value[index].id)
}

// ── Computed cells ────────────────────────────────────────────────────────────

const placedCells = computed(() =>
  children.value
    .filter(c => c.disposition_x != null && c.disposition_y != null)
    .map(c => ({
      col:      c.disposition_x,
      row:      c.disposition_y,
      label:    c.name.slice(0, 4),
      name:     c.name,
      cssClass: c.has_children ? 'grid-cell-placed grid-cell-drillable' : 'grid-cell-placed'
    }))
)

const unplacedChildren = computed(() =>
  children.value.filter(c => c.disposition_x == null && c.disposition_y == null && c.disposition_z == null)
)

// ── Cell modal ────────────────────────────────────────────────────────────────

async function onCellClick({ col, row }) {
  const occupant = children.value.find(c => c.disposition_x === col && c.disposition_y === row) || null
  placeError.value = ''
  moveError.value  = ''
  editForm.error   = ''
  modal.value = { visible: true, col, row, occupant }

  if (occupant) {
    const { body } = await AjaxCall('get', `/containers/${occupant.id}.json`)
    if (body?.id) {
      editForm.name            = body.name || ''
      editForm.percentEmpty    = body.asserted_percent_empty    ?? null
      editForm.percentEarmarked = body.asserted_percent_earmarked ?? null
      editForm.printLabel      = body.print_label || ''
    }
  }
}

function closeModal() {
  modal.value = { visible: false, col: null, row: null, occupant: null }
}

async function placeChild(item) {
  await place(item.container_item_id, modal.value.col, modal.value.row)
}

async function placeFromAutocomplete(container) {
  const child = children.value.find(c => c.id === container.id)
  if (child) {
    await place(child.container_item_id, modal.value.col, modal.value.row)
  } else {
    emit('add-container', { container, col: modal.value.col, row: modal.value.row })
    closeModal()
  }
}

async function unplaceOccupant() {
  await place(modal.value.occupant.container_item_id, null, null, null)
}

async function place(containerItemId, col, row, z = undefined) {
  placeError.value = ''
  const attrs = { disposition_x: col, disposition_y: row }
  if (z !== undefined) attrs.disposition_z = z
  const { body } = await AjaxCall('patch', `/container_items/${containerItemId}.json`, {
    container_item: attrs
  })
  if (body?.id) {
    await loadChildren(currentContainer.value.id)
    closeModal()
  } else {
    placeError.value = Object.values(body || {}).flat().join(', ') || 'Could not place container.'
  }
}

// ── Occupant attribute editing ────────────────────────────────────────────────

async function saveOccupantField(field, value) {
  if (!modal.value.occupant) return
  editForm.error = ''

  // Always send both percent fields together so the cross-field validation
  // (earmarked must not exceed empty) has both values to compare against.
  const attrs = { [field]: value }
  if (field === 'asserted_percent_empty')
    attrs.asserted_percent_earmarked = editForm.percentEarmarked
  if (field === 'asserted_percent_earmarked')
    attrs.asserted_percent_empty = editForm.percentEmpty

  let body
  try {
    ;({ body } = await AjaxCall('patch', `/containers/${modal.value.occupant.id}.json`, {
      container: attrs
    }))
  } catch (error) {
    const errors = error?.response?.body
    editForm.error = errors
      ? Object.values(errors).flat().join(', ')
      : 'Could not save.'
    return
  }

  // If the name changed, update children list and zoom stack so labels refresh
  if (field === 'name') {
    const newName = body.name
    children.value = children.value.map(c =>
      c.id === modal.value.occupant.id ? { ...c, name: newName } : c
    )
    zoomStack.value = zoomStack.value.map(z =>
      z.id === modal.value.occupant.id ? { ...z, name: newName } : z
    )
    modal.value = { ...modal.value, occupant: { ...modal.value.occupant, name: newName } }
  }
}

function setPercent(formKey, apiField, value) {
  editForm[formKey] = value
  saveOccupantField(apiField, value)
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
    const child = children.value.find(c => c.disposition_x === from.col && c.disposition_y === from.row)
    if (!child) continue
    const { body } = await AjaxCall('patch', `/container_items/${child.container_item_id}.json`, {
      container_item: { disposition_x: to.col, disposition_y: to.row }
    })
    if (!body?.id) failed.push({ child, to })
  }

  // Second pass — retry anything that bounced the first time
  const stillFailed = []
  for (const { child, to } of failed) {
    const { body } = await AjaxCall('patch', `/container_items/${child.container_item_id}.json`, {
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

// ── Expand controls (apply to current zoom target) ────────────────────────────

async function patchCurrentContainer(attrs) {
  saving.value      = true
  expandError.value = ''
  const { body } = await AjaxCall('patch', `/containers/${currentContainer.value.id}.json`, { container: attrs })
  saving.value = false
  if (body?.id) {
    // Update size in the zoom stack entry
    const idx = zoomStack.value.length - 1
    zoomStack.value = [
      ...zoomStack.value.slice(0, idx),
      { ...zoomStack.value[idx], size_x: body.size_x, size_y: body.size_y }
    ]
  } else {
    expandError.value = 'Could not update dimensions.'
  }
}

function expandRows() {
  if (!expandRowsBy.value || expandRowsBy.value < 1) return
  patchCurrentContainer({ size_y: (currentContainer.value.size_y || 0) + expandRowsBy.value })
}

function expandCols() {
  if (!expandColsBy.value || expandColsBy.value < 1) return
  patchCurrentContainer({ size_x: (currentContainer.value.size_x || 0) + expandColsBy.value })
}

defineExpose({
  reload: () => currentContainer.value && loadChildren(currentContainer.value.id)
})
</script>

<style scoped lang="scss">
@use 'sass:map';
@use '../../../../assets/styles/variables/_palette.scss' as *;
.building-grid-panel {
  margin-top: 1em;
}

/* Building name inline with heading */
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

.viz-task-link {
  display: flex;
  align-items: center;
  color: map.get($tw-colors, 'white');
}

.viz-task-link:hover {
  color: map.get($tw-colors, 'white');
}

/* Breadcrumb trail */
.breadcrumb-row {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 0.25em;
  min-height: 1.4em;
  margin-bottom: 0.5em;
  font-size: 0.88em;
  border-bottom: 1px solid #eee;
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

/* Expand controls */
.expand-controls {
  margin-bottom: 0.75em;
}

/* Modal */
.modal-body-inner {
  display: flex;
  flex-direction: column;
  gap: 0.75em;
}

.modal-two-col {
  flex-direction: row;
  align-items: flex-start;
  gap: 1.5em;
}

.modal-col-placement {
  flex: 1 1 0;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 0.75em;
}

.modal-col-edit {
  flex: 0 0 300px;
  min-width: 0;
  overflow: hidden;
  border-left: 1px solid #eee;
  padding-left: 1.5em;
  display: flex;
  flex-direction: column;
  gap: 0.75em;
}

.modal-col-edit h4 {
  margin: 0 0 0.25em;
}

.edit-field {
  display: flex;
  flex-direction: column;
  gap: 0.25em;
  font-size: 0.9em;
  min-width: 0;
}

.edit-label {
  font-weight: normal;
}

.full-width-input {
  width: 100%;
  box-sizing: border-box;
}

.slider-track-row {
  display: flex;
  align-items: center;
  gap: 0.4em;
  overflow: hidden;
  min-width: 0;
}

.range-input {
  flex: 1 1 0;
  min-width: 0;
  width: 0;
}

.slider-value {
  flex: 0 0 2.5em;
  text-align: right;
  font-size: 0.85em;
  color: #555;
}

.slider-btn-row {
  display: flex;
  gap: 0.3em;
}

.modal-divider {
  border: none;
  border-top: 1px solid #ddd;
  margin: 0.25em 0;
}

.cell-occupant {
  display: flex;
  align-items: center;
  gap: 0.5em;
}

.unplaced-list {
  list-style: none;
  margin: 0;
  padding: 0;
  max-height: 200px;
  overflow-y: auto;
}

.unplaced-item {
  padding: 4px 6px;
  border-radius: 3px;
  cursor: pointer;
  font-size: 0.9em;
}

.unplaced-item:hover {
  background: #eef4ff;
}

.icon-unplace {
  color: #43a047;
}
</style>
