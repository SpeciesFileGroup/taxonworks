<template>
  <div
    ref="rootEl"
    class="lt-root"
    tabindex="-1"
    @pointerenter="isPointerInside = true"
    @pointerleave="isPointerInside = false"
  >
    <slot
      name="toolbar"
      :light-table="lightTable"
    >
      <LightTableToolbar :readonly="readonly">
        <template #append>
          <slot name="toolbar-append" />
        </template>
      </LightTableToolbar>
    </slot>
    <LightTableRegionBar
      :readonly="readonly"
      @context-menu="
        ({ target, element }) => contextMenuRef.openBelow(target, element)
      "
    />
    <LightTableCanvas
      ref="canvasEl"
      class="lt-root__canvas"
      :readonly="readonly"
      :drop-types="dropTypes"
      @drop-external="(e) => emit('drop-external', e)"
      @context-menu="({ target, event }) => contextMenuRef.open(target, event)"
    >
      <template #item-overlay="slotProps">
        <slot
          name="item-overlay"
          v-bind="slotProps"
        />
      </template>
    </LightTableCanvas>
    <LightTableContextMenu
      ref="contextMenuRef"
      :readonly="readonly"
    >
      <template
        v-for="name in CONTEXT_MENU_SLOTS.filter(
          (n) => $slots[`${n}-context-menu`]
        )"
        :key="name"
        #[name]="slotProps"
      >
        <slot
          :name="`${name}-context-menu`"
          v-bind="slotProps"
        />
      </template>
    </LightTableContextMenu>
  </div>
</template>

<script setup>
import {
  provide,
  ref,
  computed,
  watch,
  onMounted,
  toRef,
  nextTick
} from 'vue'
import { useEventListener } from '@/composables'
import { useLightTable } from './composables/useLightTable.js'
import LightTableCanvas from './components/LightTableCanvas.vue'
import LightTableToolbar from './components/LightTableToolbar.vue'
import LightTableRegionBar from './components/LightTableRegionBar.vue'
import LightTableContextMenu from './components/LightTableContextMenu.vue'

const CONTEXT_MENU_SLOTS = ['item', 'region', 'canvas']

const props = defineProps({
  items: {
    type: Array,
    default: () => []
  },

  regions: {
    type: Array,
    default: () => []
  },

  labels: {
    type: Object,
    default: () => ({})
  },

  readonly: {
    type: Boolean,
    default: false
  },

  regionRing: {
    type: Boolean,
    default: false
  },

  dropTypes: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['select', 'change', 'drop-external'])

const lightTable = useLightTable()
const panMode = ref(false)
const isPointerInside = ref(false)
const rootEl = ref(null)
const canvasEl = ref(null)
const contextMenuRef = ref(null)

const labels = computed(() => ({
  region: 'Region',
  regions: 'Regions',
  ...props.labels
}))

provide('lightTable', lightTable)
provide('panMode', panMode)
provide('regionRing', toRef(props, 'regionRing'))
provide('ltLabels', labels)

function fitLoaded() {
  nextTick(() => lightTable.fitAll({ maxZoom: 1 }))
}

lightTable.load(props.items, props.regions)

watch([() => props.items, () => props.regions], ([items, regions]) => {
  lightTable.load(items, regions)
  fitLoaded()
})

watch(
  () => [...lightTable.selection],
  (ids) => emit('select', ids)
)

watch(
  () => ({
    i: lightTable.items.map((it) => [
      it.id,
      it.x,
      it.y,
      it.w,
      it.h,
      it.rotation,
      it.scale,
      it.opacity,
      it.z,
      it.regionId,
      it.label
    ]),
    r: lightTable.regions.map((r) => [r.id, r.name, r.color, r.x, r.y])
  }),
  () => emit('change', lightTable.exportLayout()),
  { deep: true, immediate: true }
)

function isTextTarget(el) {
  if (!el) return false
  const tag = el.tagName

  return (
    tag === 'INPUT' ||
    tag === 'TEXTAREA' ||
    tag === 'SELECT' ||
    el.isContentEditable
  )
}

function isActive() {
  return isPointerInside.value || rootEl.value?.contains(document.activeElement)
}

function onKeyDown(e) {
  if (isTextTarget(e.target) || !isActive()) return

  if (e.code === 'Space' && !panMode.value) {
    panMode.value = true
    e.preventDefault()
  } else if (e.key === 'Delete' || e.key === 'Backspace') {
    if (lightTable.selection.size && !props.readonly) {
      lightTable.removeItems([...lightTable.selection])
      e.preventDefault()
    }
  } else if (e.key === 'Escape') {
    lightTable.clearSelection()
  } else if (e.key === 'a' && (e.ctrlKey || e.metaKey)) {
    lightTable.selectOnly(lightTable.items.map((it) => it.id))
    e.preventDefault()
  }
}

function onKeyUp(e) {
  if (e.code === 'Space') panMode.value = false
}

useEventListener(window, 'keydown', onKeyDown)
useEventListener(window, 'keyup', onKeyUp)

onMounted(() => {
  lightTable.setCanvasRectProvider(
    () => canvasEl.value?.getCanvasRect?.() ?? null
  )
  fitLoaded()
})

function clientToCanvas(clientX, clientY) {
  const rect = canvasEl.value?.getCanvasRect?.()
  if (!rect) return null

  return lightTable.viewport.screenToCanvas(clientX, clientY, rect)
}

defineExpose({
  items: lightTable.items,
  regions: lightTable.regions,
  selection: lightTable.selection,
  addItems: lightTable.addItems,
  removeItems: lightTable.removeItems,
  updateItemMeta: lightTable.updateItemMeta,
  createRegion: lightTable.createRegion,
  updateRegion: lightTable.updateRegion,
  removeRegion: lightTable.removeRegion,
  assignToRegion: lightTable.assignToRegion,
  packRegion: lightTable.packRegion,
  membersOfRegion: lightTable.membersOfRegion,
  getRegionOfItem: lightTable.getRegionOfItem,
  selectOnly: lightTable.selectOnly,
  clearSelection: lightTable.clearSelection,
  exportLayout: lightTable.exportLayout,
  fitAll: lightTable.fitAll,
  fitSelection: lightTable.fitSelection,
  fitRegion: lightTable.fitRegion,
  clientToCanvas
})
</script>

<style scoped>
.lt-root {
  display: flex;
  flex-direction: column;
  width: 100%;
  height: 100%;
  color: var(--text-color);
  outline: none;
}

.lt-root__canvas {
  flex: 1 1 auto;
  min-height: 0;
}
</style>
