<template>
  <SaveBar @close="emit('close')" />
  <div class="light-table-editor">
    <SourcePanel
      class="light-table-editor__side"
      :placed-keys="placedKeys"
      @add="(payload) => addFromSource(payload)"
    />
    <div class="panel light-table-editor__canvas">
      <LightTable
        ref="lightTableRef"
        :items="store.initialItems"
        :regions="store.initialRegions"
        :labels="LABELS"
        :drop-types="[DRAG_TYPE]"
        @change="store.setLayout"
        @select="(ids) => (selectedIds = ids)"
        @drop-external="onDrop"
      />
    </div>
    <SelectionPanel
      class="light-table-editor__side"
      :items="selectedItems"
      :regions="store.layout?.regions || []"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { Image } from '@/routes/endpoints'
import { LightTable } from '@/components/LightTable'
import { DRAG_TYPE, LABELS, OBJECT_DEPICTION, OBJECT_IMAGE } from '../constants'
import { objectToSource } from '../adapters/source'
import useStore from '../store/store'
import SaveBar from './SaveBar.vue'
import SelectionPanel from './SelectionPanel.vue'
import SourcePanel from './sources/SourcePanel.vue'

const MAX_FILTER_IMAGES = 500
const DROP_OFFSET = 20

const props = defineProps({
  // Image filter params, e.g. from the radial linker
  imageQuery: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['close'])

const store = useStore()
const lightTableRef = ref(null)
const selectedIds = ref([])

const layoutItems = computed(() => store.layout?.items || [])

const placedKeys = computed(
  () =>
    new Set(
      layoutItems.value.map((it) => `${it.meta.objectType}:${it.meta.objectId}`)
    )
)

const selectedItems = computed(() => {
  const ids = new Set(selectedIds.value)

  return layoutItems.value.filter((it) => ids.has(it.id))
})

// The group of an OTU: the one holding most of its depictions. A group
// references no object, its members do.
function findOtuRegion(depictionIds) {
  const ids = new Set(depictionIds)
  const counts = new Map()

  for (const item of lightTableRef.value.items) {
    if (
      item.regionId &&
      item.meta.objectType === OBJECT_DEPICTION &&
      ids.has(item.meta.objectId)
    ) {
      counts.set(item.regionId, (counts.get(item.regionId) || 0) + 1)
    }
  }

  return [...counts.entries()].sort((a, b) => b[1] - a[1])[0]?.[0] ?? null
}

// @param payload { objectType, objects, otu?, depictionIds? }, see sources/
// @param point [Object] canvas coordinates of a drop
function addFromSource(payload, point = null) {
  const lightTable = lightTableRef.value
  const sources = payload.objects
    .map((object) => objectToSource(payload.objectType, object))
    .filter(
      (s) => !placedKeys.value.has(`${s.meta.objectType}:${s.meta.objectId}`)
    )

  const skipped = payload.objects.length - sources.length

  if (skipped) {
    TW.workbench.alert.create(
      `${skipped} image(s) already on the light table.`,
      'notice'
    )
  }

  if (!sources.length) return

  let regionId = null
  let isNewRegion = false

  if (payload.otu) {
    regionId = findOtuRegion(payload.depictionIds)

    if (!regionId) {
      isNewRegion = true
      regionId = lightTable.createRegion({
        name: payload.otu.label,
        ...(point && { x: point.x, y: point.y })
      })
    }
  }

  const ids = lightTable.addItems(
    sources.map((source, i) => ({
      ...source,
      regionId,
      ...(point && {
        x: point.x + i * DROP_OFFSET,
        y: point.y + i * DROP_OFFSET
      })
    }))
  )

  if (isNewRegion && sources.length > 1) {
    lightTable.packRegion(regionId)
  }

  lightTable.selectOnly(ids)
}

function onDrop({ point, dataTransfer }) {
  try {
    addFromSource(JSON.parse(dataTransfer.getData(DRAG_TYPE)), point)
  } catch {
    // not a payload of ours
  }
}

function addImagesFromQuery(params) {
  Image.filter({ ...params, per: MAX_FILTER_IMAGES })
    .then(({ body }) => {
      addFromSource({ objectType: OBJECT_IMAGE, objects: body })
    })
    .catch(() => {})
}

onMounted(() => {
  if (props.imageQuery) addImagesFromQuery(props.imageQuery)
})
</script>

<style scoped>
.light-table-editor {
  display: grid;
  grid-template-columns: 280px minmax(0, 1fr) 260px;
  gap: var(--spacing-md);
  align-items: start;
}

.light-table-editor__canvas {
  height: calc(100vh - 220px);
  min-height: 480px;
  overflow: hidden;
}

.light-table-editor__side {
  max-height: calc(100vh - 220px);
  overflow-y: auto;
}
</style>
