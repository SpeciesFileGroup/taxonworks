import { reactive, computed } from 'vue'
import { useViewport } from './useViewport.js'
import {
  REGION_HEADER_H,
  REGION_PAD,
  fitSize,
  gridDimsForCount,
  itemAABB,
  pointInArea,
  regionAreaFor,
  unionBounds
} from '../utils/geometry.js'
import { parseViewBox } from '../utils/svg.js'

let _idSeq = 0
let _ridSeq = 0
const nextId = () => `lt-${Date.now().toString(36)}-${++_idSeq}`
const nextRid = () => `lt-r-${Date.now().toString(36)}-${++_ridSeq}`

export const MAX_ITEM_WIDTH = 320
const DEFAULT_W = 240
const DEFAULT_H = 180
const PLACEMENT_GAP = 40
const PLACEMENT_COLS = 4
const START_X = 40
const START_Y = 40

const DEFAULT_PALETTE = [
  '#e63946',
  '#f4a261',
  '#e9c46a',
  '#2a9d8f',
  '#577590',
  '#9b5de5',
  '#f15bb5',
  '#00bbf9',
  '#fb8500',
  '#7209b7',
  '#3a86ff',
  '#43aa8b'
]

export function itemBaseSize(img) {
  if (img.w && img.h) return { w: img.w, h: img.h, loaded: true }

  const box = parseViewBox(img.viewBox)
  const size = box
    ? fitSize(box.w, box.h, MAX_ITEM_WIDTH)
    : fitSize(img.mediaWidth, img.mediaHeight, MAX_ITEM_WIDTH)

  return size
    ? { ...size, loaded: true }
    : { w: DEFAULT_W, h: DEFAULT_H, loaded: false }
}

function makeItem(img, z) {
  const hasPosition = img.x != null && img.y != null
  const { w, h, loaded } = itemBaseSize(img)

  return {
    id: img.id ?? nextId(),
    src: img.src,
    alt: img.alt ?? '',
    label: img.label ?? '',
    mediaWidth: img.mediaWidth ?? null,
    mediaHeight: img.mediaHeight ?? null,
    viewBox: img.viewBox ?? null,
    clipPath: img.clipPath ?? null,
    w,
    h,
    loaded,
    meta: img.meta ?? {},
    x: hasPosition ? img.x : null,
    y: hasPosition ? img.y : null,
    rotation: img.rotation ?? 0,
    scale: img.scale ?? 1,
    opacity: img.opacity ?? 1,
    z: img.z ?? z,
    regionId: img.regionId ?? null
  }
}

function makeRegion(r, color) {
  return {
    id: r.id ?? nextRid(),
    name: r.name ?? '',
    color: r.color ?? color,
    x: r.x ?? 0,
    y: r.y ?? 0
  }
}

export function useLightTable() {
  const viewport = useViewport()
  const items = reactive([])
  const selection = reactive(new Set())
  const regions = reactive([])

  const selectedItems = computed(() =>
    items.filter((it) => selection.has(it.id))
  )

  const regionAreas = computed(() => {
    const areas = new Map()

    for (const r of regions) {
      areas.set(r.id, regionAreaFor(r, membersOfRegion(r.id)))
    }

    return areas
  })

  function pickRegionColor() {
    const used = new Set(regions.map((r) => r.color))

    return (
      DEFAULT_PALETTE.find((c) => !used.has(c)) ??
      DEFAULT_PALETTE[regions.length % DEFAULT_PALETTE.length]
    )
  }

  function load(newImages = [], newRegions = []) {
    regions.splice(0, regions.length)
    newRegions.forEach((r) => regions.push(makeRegion(r, pickRegionColor())))

    items.splice(
      0,
      items.length,
      ...newImages.map((img, i) => makeItem(img, i + 1))
    )
    placeUnpositioned()
    selection.clear()
  }

  function findById(id) {
    return items.find((it) => it.id === id)
  }

  function findRegionById(id) {
    return regions.find((r) => r.id === id)
  }

  function membersOfRegion(regionId) {
    return items.filter((it) => it.regionId === regionId)
  }

  function maxZ() {
    return items.reduce((m, it) => Math.max(m, it.z), 0)
  }

  function placeInGrid(list, x, y) {
    if (!list.length) return
    const cellW = Math.max(...list.map((it) => it.w * it.scale)) + PLACEMENT_GAP
    const cellH = Math.max(...list.map((it) => it.h * it.scale)) + PLACEMENT_GAP

    list.forEach((it, i) => {
      it.x = x + cellW * (i % PLACEMENT_COLS) + cellW / 2
      it.y = y + cellH * Math.floor(i / PLACEMENT_COLS) + cellH / 2
    })
  }

  function placeUnpositioned() {
    const pending = items.filter((it) => it.x == null || it.y == null)
    if (!pending.length) return

    const placed = items.filter((it) => it.x != null && it.y != null)
    const byRegion = new Map()
    const loose = []

    for (const it of pending) {
      const r = it.regionId && findRegionById(it.regionId)

      if (r) {
        if (!byRegion.has(r.id)) byRegion.set(r.id, [])
        byRegion.get(r.id).push(it)
      } else {
        loose.push(it)
      }
    }

    for (const [rid, list] of byRegion) {
      const r = findRegionById(rid)
      const members = placed.filter((it) => it.regionId === rid)
      const bounds = unionBounds(members.map(itemAABB))

      if (bounds) {
        placeInGrid(list, bounds.x + bounds.w + PLACEMENT_GAP / 2, bounds.y)
      } else {
        placeInGrid(list, r.x + REGION_PAD, r.y + REGION_HEADER_H + REGION_PAD)
      }
    }

    const bounds = unionBounds(items.filter((it) => it.x != null).map(itemAABB))

    placeInGrid(
      loose,
      bounds ? bounds.x : START_X,
      bounds ? bounds.y + bounds.h + PLACEMENT_GAP * 2 : START_Y
    )
  }

  function addItems(newImages) {
    const z = maxZ()
    const added = newImages.map((img, i) => makeItem(img, z + i + 1))

    items.push(...added)
    placeUnpositioned()

    return added.map((it) => it.id)
  }

  function removeItems(ids) {
    const idSet = new Set(ids)

    for (let i = items.length - 1; i >= 0; i--) {
      if (idSet.has(items[i].id)) items.splice(i, 1)
    }
    ids.forEach((id) => selection.delete(id))
  }

  function setItemSize(id, w, h) {
    const it = findById(id)
    if (!it) return
    it.w = w
    it.h = h
    it.loaded = true
  }

  function transformItem(id, patch) {
    const it = findById(id)
    if (it) Object.assign(it, patch)
  }

  function setLabel(id, label) {
    const it = findById(id)
    if (it) it.label = label
  }

  function nudgeSelected(dx, dy) {
    selection.forEach((id) => {
      const it = findById(id)
      if (it) {
        it.x += dx
        it.y += dy
      }
    })
  }

  function bringToFront(ids = [...selection]) {
    const top = maxZ()

    ids.forEach((id, i) => {
      const it = findById(id)
      if (it) it.z = top + 1 + i
    })
  }

  function sendToBack(ids = [...selection]) {
    const minZ = items.reduce((m, it) => Math.min(m, it.z), 1)

    ids.forEach((id, i) => {
      const it = findById(id)
      if (it) it.z = minZ - 1 - i
    })
  }

  function swapZ(ids, direction) {
    ids.forEach((id) => {
      const it = findById(id)
      if (!it) return
      const next = items
        .filter((o) => o.id !== id && (direction > 0 ? o.z > it.z : o.z < it.z))
        .sort((a, b) => (a.z - b.z) * direction)[0]

      if (next) {
        const tmp = it.z
        it.z = next.z
        next.z = tmp
      }
    })
  }

  function bringForward(ids = [...selection]) {
    swapZ(ids, 1)
  }

  function sendBackward(ids = [...selection]) {
    swapZ(ids, -1)
  }

  function selectOnly(ids) {
    selection.clear()
    ids.forEach((id) => selection.add(id))
  }

  function toggleSelect(id) {
    if (selection.has(id)) selection.delete(id)
    else selection.add(id)
  }

  function addToSelection(ids) {
    ids.forEach((id) => selection.add(id))
  }

  function clearSelection() {
    selection.clear()
  }

  function resetTransform(ids = [...selection]) {
    ids.forEach((id) => {
      const it = findById(id)
      if (it) {
        it.rotation = 0
        it.scale = 1
        it.opacity = 1
      }
    })
  }

  function setOpacity(value, ids = [...selection]) {
    const v = Math.min(1, Math.max(0, value))

    ids.forEach((id) => {
      const it = findById(id)
      if (it) it.opacity = v
    })
  }

  function nextRegionOrigin() {
    const bounds = contentBounds()

    return bounds
      ? { x: bounds.x + bounds.w + PLACEMENT_GAP * 2, y: bounds.y }
      : { x: START_X, y: START_Y }
  }

  function createRegion({ id, name, color, x, y } = {}) {
    const origin = x != null && y != null ? { x, y } : nextRegionOrigin()
    const region = makeRegion({ id, name, color, ...origin }, pickRegionColor())

    regions.push(region)

    return region.id
  }

  function updateRegion(id, patch) {
    const r = findRegionById(id)
    if (r) Object.assign(r, patch)
  }

  function moveRegion(id, dx, dy) {
    const r = findRegionById(id)
    if (!r) return

    r.x += dx
    r.y += dy
    membersOfRegion(id).forEach((it) => {
      it.x += dx
      it.y += dy
    })
  }

  function removeRegion(id) {
    const i = regions.findIndex((r) => r.id === id)
    if (i < 0) return

    regions.splice(i, 1)
    items.forEach((it) => {
      if (it.regionId === id) it.regionId = null
    })
  }

  function assignToRegion(ids, regionId) {
    ids.forEach((id) => {
      const it = findById(id)
      if (it) it.regionId = regionId
    })
  }

  function unassignSelected() {
    assignToRegion([...selection], null)
  }

  function regionFromSelection(opts = {}) {
    const bounds = selectionBounds()
    if (!bounds) return createRegion(opts)

    const ids = [...selection]
    const rid = createRegion({
      ...opts,
      x: bounds.x - REGION_PAD,
      y: bounds.y - REGION_PAD - REGION_HEADER_H
    })

    assignToRegion(ids, rid)

    return rid
  }

  function regionArea(id) {
    return regionAreas.value.get(id) ?? null
  }

  function findRegionContaining(item) {
    const matches = regions
      .filter((r) => r.id !== item.regionId)
      .map((r) => ({ r, area: regionArea(r.id) }))
      .filter(({ area }) => pointInArea(item.x, item.y, area))

    if (!matches.length) return null

    return matches.reduce((smallest, m) =>
      m.area.w * m.area.h < smallest.area.w * smallest.area.h ? m : smallest
    ).r
  }

  function claimSelected() {
    selection.forEach((id) => {
      const it = findById(id)
      if (!it) return
      const target = findRegionContaining(it)
      if (target) it.regionId = target.id
    })
  }

  function packRegion(id, { gap = 24 } = {}) {
    const members = membersOfRegion(id)
    const area = regionArea(id)
    if (!members.length || !area) return

    const cellW = Math.max(...members.map((it) => it.w * it.scale)) + gap
    const cellH = Math.max(...members.map((it) => it.h * it.scale)) + gap
    const { cols } = gridDimsForCount(members.length, cellW / cellH)
    const usableX = area.x + REGION_PAD
    const usableY = area.y + REGION_HEADER_H + REGION_PAD

    members.forEach((it, i) => {
      it.x = usableX + cellW * (i % cols) + cellW / 2
      it.y = usableY + cellH * Math.floor(i / cols) + cellH / 2
    })
  }

  function regionColorFor(item) {
    if (!item?.regionId) return null

    return findRegionById(item.regionId)?.color ?? null
  }

  function getRegionOfItem(id) {
    const it = findById(id)

    return it?.regionId ? (findRegionById(it.regionId) ?? null) : null
  }

  function exportLayout() {
    return {
      items: items.map((it) => ({
        id: it.id,
        x: it.x,
        y: it.y,
        w: it.w,
        h: it.h,
        rotation: it.rotation,
        scale: it.scale,
        opacity: it.opacity,
        z: it.z,
        regionId: it.regionId,
        label: it.label,
        meta: it.meta
      })),
      regions: regions.map((r) => ({
        id: r.id,
        name: r.name,
        color: r.color,
        x: r.x,
        y: r.y
      }))
    }
  }

  function itemsIntersecting(rect) {
    return items.filter((it) => {
      const b = itemAABB(it)

      return !(
        b.x + b.w < rect.x ||
        b.x > rect.x + rect.w ||
        b.y + b.h < rect.y ||
        b.y > rect.y + rect.h
      )
    })
  }

  function contentBounds() {
    const boxes = items.filter((it) => it.x != null).map(itemAABB)

    regions.forEach((r) => {
      if (!membersOfRegion(r.id).length) boxes.push(regionArea(r.id))
    })

    return unionBounds(boxes.filter(Boolean))
  }

  function selectionBounds() {
    return unionBounds(selectedItems.value.map(itemAABB))
  }

  let canvasRectProvider = null

  function setCanvasRectProvider(fn) {
    canvasRectProvider = typeof fn === 'function' ? fn : null
  }

  function fitBounds(bounds, opts) {
    const rect = canvasRectProvider?.()
    if (rect && bounds) viewport.fitBounds(bounds, rect, opts)
  }

  function fitAll(opts) {
    fitBounds(contentBounds(), opts)
  }

  function fitSelection() {
    fitBounds(selectionBounds())
  }

  function fitRegion(id) {
    fitBounds(regionArea(id), { padding: 80 })
  }

  function alignSelected(edge) {
    const list = selectedItems.value
    if (list.length < 2) return

    const boxes = list.map((it) => ({ it, b: itemAABB(it) }))
    const minX = Math.min(...boxes.map((o) => o.b.x))
    const maxX = Math.max(...boxes.map((o) => o.b.x + o.b.w))
    const minY = Math.min(...boxes.map((o) => o.b.y))
    const maxY = Math.max(...boxes.map((o) => o.b.y + o.b.h))
    const cx = (minX + maxX) / 2
    const cy = (minY + maxY) / 2

    for (const { it, b } of boxes) {
      switch (edge) {
        case 'left':
          it.x += minX - b.x
          break
        case 'right':
          it.x += maxX - (b.x + b.w)
          break
        case 'hcenter':
          it.x += cx - (b.x + b.w / 2)
          break
        case 'top':
          it.y += minY - b.y
          break
        case 'bottom':
          it.y += maxY - (b.y + b.h)
          break
        case 'vcenter':
          it.y += cy - (b.y + b.h / 2)
          break
      }
    }
  }

  function distributeSelected(axis) {
    const list = selectedItems.value
    if (list.length < 3) return

    const key = axis === 'vertical' ? 'y' : 'x'
    const sorted = [...list].sort((a, b) => a[key] - b[key])
    const first = sorted[0][key]
    const last = sorted[sorted.length - 1][key]
    const step = (last - first) / (sorted.length - 1)

    sorted.forEach((it, i) => {
      it[key] = first + step * i
    })
  }

  return {
    viewport,
    items,
    selection,
    selectedItems,
    regions,
    load,
    addItems,
    removeItems,
    setItemSize,
    transformItem,
    setOpacity,
    setLabel,
    nudgeSelected,
    bringToFront,
    sendToBack,
    bringForward,
    sendBackward,
    resetTransform,
    selectOnly,
    toggleSelect,
    addToSelection,
    clearSelection,
    createRegion,
    updateRegion,
    moveRegion,
    removeRegion,
    assignToRegion,
    regionFromSelection,
    unassignSelected,
    claimSelected,
    packRegion,
    regionArea,
    regionColorFor,
    getRegionOfItem,
    membersOfRegion,
    findRegionContaining,
    exportLayout,
    itemsIntersecting,
    contentBounds,
    selectionBounds,
    setCanvasRectProvider,
    fitAll,
    fitSelection,
    fitRegion,
    alignSelected,
    distributeSelected
  }
}
