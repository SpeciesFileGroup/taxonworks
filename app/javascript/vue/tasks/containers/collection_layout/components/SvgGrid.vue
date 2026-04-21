<template>
  <div
    class="grid-scroll"
    tabindex="0"
    @keydown.esc="clearSelection"
  >
    <svg
      ref="svgRef"
      :width="svgWidth"
      :height="svgHeight"
      class="svg-grid"
      :class="{ 'is-dragging': drag.active, 'is-box-selecting': box.active }"
      @mousedown.prevent="onMousedown"
      @dblclick="onDblclick"
    >
      <!-- Column labels (x) -->
      <text
        v-for="col in cols"
        :key="`col-label-${col}`"
        :x="originX + (col - 1) * cellSize + cellSize / 2"
        :y="originY - 4"
        text-anchor="middle"
        class="grid-label"
      >{{ col }}</text>

      <!-- Row labels (y) -->
      <text
        v-for="row in rows"
        :key="`row-label-${row}`"
        :x="originX - 4"
        :y="originY + (row - 1) * cellSize + cellSize / 2 + 4"
        text-anchor="end"
        class="grid-label"
      >{{ row }}</text>

      <!-- Base cells -->
      <g
        v-for="row in rows"
        :key="`row-${row}`"
      >
        <rect
          v-for="col in cols"
          :key="`cell-${col}-${row}`"
          :x="originX + (col - 1) * cellSize"
          :y="originY + (row - 1) * cellSize"
          :width="cellSize - 1"
          :height="cellSize - 1"
          :class="cellClasses(col, row)"
          :fill="cellFill(col, row)"
        />
        <text
          v-for="col in cols"
          :key="`cell-label-${col}-${row}`"
          :x="originX + (col - 1) * cellSize + cellSize / 2"
          :y="originY + (row - 1) * cellSize + cellSize / 2 + 3"
          text-anchor="middle"
          class="cell-label"
        >{{ cellLabel(col, row) }}</text>
      </g>

      <!-- Drag ghost -->
      <g
        v-if="drag.active && drag.moving"
        class="drag-ghost"
        :class="{ 'drag-ghost-invalid': !dragValid }"
      >
        <rect
          v-for="gc in ghostCells"
          :key="`ghost-${gc.col}-${gc.row}`"
          :x="originX + (gc.col - 1) * cellSize"
          :y="originY + (gc.row - 1) * cellSize"
          :width="cellSize - 1"
          :height="cellSize - 1"
          class="ghost-rect"
        />
      </g>

      <!-- Box-select rectangle -->
      <rect
        v-if="box.active && box.moving"
        :x="boxRect.x"
        :y="boxRect.y"
        :width="boxRect.w"
        :height="boxRect.h"
        class="box-select-rect"
      />
    </svg>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onBeforeUnmount } from 'vue'

const props = defineProps({
  cols: {
    type: Number,
    required: true
  },
  rows: {
    type: Number,
    required: true
  },
  // [{ col, row, label, fill, cssClass }]
  cells: {
    type: Array,
    default: () => []
  },
  cellSize: {
    type: Number,
    default: 20
  }
})

const emit = defineEmits(['cell-click', 'cell-dblclick', 'move'])

const DRAG_THRESHOLD  = 4   // px before a mousedown becomes a drag
const DBLCLICK_WINDOW = 250 // ms to wait before confirming a single click

const originX = 24
const originY = 20

const svgRef   = ref(null)
const selected = ref(new Set()) // Set of "col,row" strings

let clickTimer   = null
let pendingClick = null


// ── Drag state ────────────────────────────────────────────────────────────────
const drag = reactive({
  active:      false,
  moving:      false,
  fromCells:   [],       // [{col, row}]
  startSvg:    { x: 0, y: 0 },
  dcol:        0,
  drow:        0,
  pendingCell: null      // cell targeted by mousedown, used to emit cell-click on mouseup
})

// ── Box-select state ──────────────────────────────────────────────────────────
const box = reactive({
  active:    false,
  moving:    false,
  startSvg:  { x: 0, y: 0 },
  currentSvg:{ x: 0, y: 0 }
})

// ── Computed layout ───────────────────────────────────────────────────────────

const svgWidth  = computed(() => originX + props.cols * props.cellSize + 4)
const svgHeight = computed(() => originY + props.rows * props.cellSize + 4)

// ── Cell helpers ──────────────────────────────────────────────────────────────

function cellAt(col, row) {
  return props.cells.find(c => c.col === col && c.row === row) || null
}

function cellFill(col, row) {
  return cellAt(col, row)?.fill || null
}

function cellLabel(col, row) {
  if (drag.active && drag.moving && drag.fromCells.some(c => c.col === col && c.row === row))
    return ''
  return cellAt(col, row)?.label || ''
}

function cellClasses(col, row) {
  const key  = `${col},${row}`
  const base = cellAt(col, row)?.cssClass || 'grid-cell-empty'
  const isDragged = drag.active && drag.moving &&
    drag.fromCells.some(c => c.col === col && c.row === row)
  return [
    'grid-cell',
    base,
    selected.value.has(key)  && 'grid-cell-selected',
    isDragged                 && 'grid-cell-dragging'
  ].filter(Boolean)
}

// ── Drag computed ─────────────────────────────────────────────────────────────

const ghostCells = computed(() => {
  if (!drag.active || !drag.moving) return []
  return drag.fromCells.map(c => ({ col: c.col + drag.dcol, row: c.row + drag.drow }))
})

const movingKeys = computed(() => new Set(drag.fromCells.map(c => `${c.col},${c.row}`)))

const dragValid = computed(() => {
  if (!drag.active || !drag.moving) return true
  return ghostCells.value.every(gc => {
    if (gc.col < 1 || gc.col > props.cols || gc.row < 1 || gc.row > props.rows) return false
    const occupant = cellAt(gc.col, gc.row)
    return !occupant || movingKeys.value.has(`${gc.col},${gc.row}`)
  })
})

// ── Box-select computed ───────────────────────────────────────────────────────

const boxRect = computed(() => {
  const x1 = Math.min(box.startSvg.x, box.currentSvg.x)
  const y1 = Math.min(box.startSvg.y, box.currentSvg.y)
  const x2 = Math.max(box.startSvg.x, box.currentSvg.x)
  const y2 = Math.max(box.startSvg.y, box.currentSvg.y)
  return { x: x1, y: y1, w: Math.max(x2 - x1, 1), h: Math.max(y2 - y1, 1) }
})

// ── SVG coordinate helpers ────────────────────────────────────────────────────

function svgCoords(event) {
  if (!svgRef.value) return { x: 0, y: 0 }
  const rect = svgRef.value.getBoundingClientRect()
  return { x: event.clientX - rect.left, y: event.clientY - rect.top }
}

function svgToCell(x, y) {
  return {
    col: Math.floor((x - originX) / props.cellSize) + 1,
    row: Math.floor((y - originY) / props.cellSize) + 1
  }
}

function inGrid(col, row) {
  return col >= 1 && col <= props.cols && row >= 1 && row <= props.rows
}

// ── Mouse event handlers ──────────────────────────────────────────────────────

function onMousedown(event) {
  const pos  = svgCoords(event)
  const cell = svgToCell(pos.x, pos.y)

  if (event.shiftKey) {
    // Start box selection
    box.active     = true
    box.moving     = false
    box.startSvg   = pos
    box.currentSvg = pos
    window.addEventListener('mousemove', onWindowMousemove)
    window.addEventListener('mouseup',   onWindowMouseup)
    return
  }

  // Track the mousedown cell so mouseup can emit cell-click if no drag occurs
  drag.pendingCell = inGrid(cell.col, cell.row) ? { col: cell.col, row: cell.row } : null

  // Plain mousedown on a placed cell — start drag
  if (inGrid(cell.col, cell.row) && cellAt(cell.col, cell.row)) {
    const key = `${cell.col},${cell.row}`
    const fromCells = selected.value.has(key) && selected.value.size > 1
      ? [...selected.value].map(k => { const [c, r] = k.split(',').map(Number); return { col: c, row: r } })
      : [{ col: cell.col, row: cell.row }]

    drag.active    = true
    drag.moving    = false
    drag.fromCells = fromCells
    drag.startSvg  = pos
    drag.dcol      = 0
    drag.drow      = 0
  } else {
    selected.value = new Set()
  }

  window.addEventListener('mousemove', onWindowMousemove)
  window.addEventListener('mouseup',   onWindowMouseup)
}

function onWindowMousemove(event) {
  const pos = svgCoords(event)
  const dx  = pos.x - (drag.active ? drag.startSvg.x : box.startSvg.x)
  const dy  = pos.y - (drag.active ? drag.startSvg.y : box.startSvg.y)

  if (drag.active) {
    if (!drag.moving && (Math.abs(dx) > DRAG_THRESHOLD || Math.abs(dy) > DRAG_THRESHOLD))
      drag.moving = true
    if (drag.moving) {
      drag.dcol = Math.round(dx / props.cellSize)
      drag.drow = Math.round(dy / props.cellSize)
    }
  }

  if (box.active) {
    if (!box.moving && (Math.abs(dx) > DRAG_THRESHOLD || Math.abs(dy) > DRAG_THRESHOLD))
      box.moving = true
    if (box.moving)
      box.currentSvg = pos
  }
}

function onWindowMouseup(event) {
  window.removeEventListener('mousemove', onWindowMousemove)
  window.removeEventListener('mouseup',   onWindowMouseup)

  const pos  = svgCoords(event)
  const cell = svgToCell(pos.x, pos.y)

  if (drag.active) {
    if (drag.moving) {
      // Commit move if valid and something actually moved
      if (dragValid.value && (drag.dcol !== 0 || drag.drow !== 0)) {
        const moves = drag.fromCells.map(c => ({
          from: { col: c.col,             row: c.row },
          to:   { col: c.col + drag.dcol,  row: c.row + drag.drow }
        }))
        emit('move', moves)
        selected.value = new Set()
      }
    } else {
      // Mousedown on a placed cell that didn't move — treat as click
      selected.value = new Set()
      if (drag.pendingCell)
        scheduleCellClick(drag.pendingCell)
    }
    drag.active      = false
    drag.moving      = false
    drag.pendingCell = null
  }

  if (box.active) {
    if (box.moving) {
      // Toggle placed cells within the box rectangle
      const r = boxRect.value
      for (let c = 1; c <= props.cols; c++) {
        for (let r2 = 1; r2 <= props.rows; r2++) {
          const cx = originX + (c - 1) * props.cellSize + props.cellSize / 2
          const cy = originY + (r2 - 1) * props.cellSize + props.cellSize / 2
          if (cx >= r.x && cx <= r.x + r.w && cy >= r.y && cy <= r.y + r.h && cellAt(c, r2)) {
            const key = `${c},${r2}`
            const next = new Set(selected.value)
            next.has(key) ? next.delete(key) : next.add(key)
            selected.value = next
          }
        }
      }
    } else {
      // Was a shift-click — toggle just the start cell
      if (inGrid(cell.col, cell.row) && cellAt(cell.col, cell.row)) {
        const key  = `${cell.col},${cell.row}`
        const next = new Set(selected.value)
        next.has(key) ? next.delete(key) : next.add(key)
        selected.value = next
      }
    }
    box.active = false
    box.moving = false
  }

  // No drag, no box-select — plain click on any cell (including empty)
  if (!drag.active && !box.active && drag.pendingCell) {
    scheduleCellClick(drag.pendingCell)
    drag.pendingCell = null
  }
}

// ── Click / double-click disambiguation ───────────────────────────────────────

function scheduleCellClick(cell) {
  clearTimeout(clickTimer)
  pendingClick = cell
  clickTimer = setTimeout(() => {
    emit('cell-click', pendingClick)
    pendingClick = null
    clickTimer   = null
  }, DBLCLICK_WINDOW)
}

function onDblclick(event) {
  // Cancel the scheduled single-click and drill down instead
  clearTimeout(clickTimer)
  clickTimer   = null
  pendingClick = null

  if (!svgRef.value) return
  const pos  = svgCoords(event)
  const cell = svgToCell(pos.x, pos.y)
  if (inGrid(cell.col, cell.row))
    emit('cell-dblclick', { col: cell.col, row: cell.row })
}

function clearSelection() {
  selected.value = new Set()
}

onBeforeUnmount(() => {
  clearTimeout(clickTimer)
  window.removeEventListener('mousemove', onWindowMousemove)
  window.removeEventListener('mouseup',   onWindowMouseup)
})
</script>

<style scoped>
.grid-scroll {
  overflow: auto;
  outline: none;
}

.svg-grid {
  display: block;
  user-select: none;
}

.is-dragging  { cursor: grabbing; }
.is-box-selecting { cursor: crosshair; }

.grid-label {
  font-size: 9px;
  fill: #888;
  font-family: sans-serif;
  pointer-events: none;
}

.cell-label {
  font-size: 7px;
  fill: #555;
  font-family: sans-serif;
  pointer-events: none;
}

.grid-cell {
  cursor: pointer;
}

.grid-cell-empty {
  fill: #f4f4f4;
  stroke: #ccc;
  stroke-width: 1;
}

.grid-cell-empty:hover {
  fill: #ddeeff;
  stroke: #6699cc;
}

.grid-cell-placed {
  fill: #c8e6c9;
  stroke: #66bb6a;
  stroke-width: 1;
}

.grid-cell-placed:hover {
  fill: #a5d6a7;
  stroke: #43a047;
}

/* Placed cells that have children — dashed stroke signals drill-down available */
.grid-cell-drillable {
  stroke-dasharray: 3 2;
  cursor: zoom-in;
}

.grid-cell-selected {
  stroke: #1565c0;
  stroke-width: 2;
}

.grid-cell-dragging {
  opacity: 0.35;
}

/* Ghost overlay */
.drag-ghost .ghost-rect {
  fill: #90caf9;
  stroke: #1e88e5;
  stroke-width: 1.5;
  opacity: 0.75;
  pointer-events: none;
}

.drag-ghost-invalid .ghost-rect {
  fill: #ef9a9a;
  stroke: #e53935;
}

/* Box-select overlay */
.box-select-rect {
  fill: rgba(25, 118, 210, 0.08);
  stroke: #1976d2;
  stroke-width: 1;
  stroke-dasharray: 4 2;
  pointer-events: none;
}
</style>
