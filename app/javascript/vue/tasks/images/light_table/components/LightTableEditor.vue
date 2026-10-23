<template>
  <SaveBar
    @open="emit('open')"
    @new="emit('new')"
  />
  <div class="light-table-editor">
    <SourcePanel
      class="light-table-editor__side"
      :placed-keys="placedKeys"
      :filter-images="store.filterImages"
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
      >
        <template #item-context-menu="{ items }">
          <ItemContextMenu
            :items="items"
            @radial="openItemRadial"
            @assign-otu="isApplyOtuVisible = true"
          />
        </template>
      </LightTable>
      <component
        :is="radial.component"
        v-if="radial"
        ref="radialRef"
        v-bind="radial.props"
        :show-bottom="false"
      />
    </div>
    <SelectionPanel
      class="light-table-editor__side"
      :items="selectedItems"
      :regions="store.layout?.regions || []"
      @select="(id) => lightTableRef.selectOnly([id])"
      @deselect="
        (id) => lightTableRef.selectOnly(selectedIds.filter((i) => i !== id))
      "
      @apply-otu="isApplyOtuVisible = true"
    />
  </div>
  <ApplyOtuModal
    v-if="isApplyOtuVisible"
    :items="selectedItems"
    @close="isApplyOtuVisible = false"
    @applied="onOtuApplied"
  />
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { Image } from '@/routes/endpoints'
import { LightTable } from '@/components/LightTable'
import { ANATOMICAL_PART, IMAGE } from '@/constants'
import { DETERMINABLE_TYPES } from '../adapters/applyOtu'
import { DRAG_TYPE, LABELS } from '../constants'
import { imageKey, objectToSource } from '../adapters/source'
import useStore from '../store/store'
import SaveBar from './SaveBar.vue'
import SelectionPanel from './SelectionPanel.vue'
import SourcePanel from './sources/SourcePanel.vue'
import ItemContextMenu from './ItemContextMenu.vue'
import ApplyOtuModal from './ApplyOtuModal.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import { useRadialOpener } from '../composables/useRadialOpener'

const MAX_FILTER_IMAGES = 500
const DROP_OFFSET = 20

const RADIAL_COMPONENTS = {
  annotator: RadialAnnotator,
  navigator: RadialNavigator
}

const props = defineProps({
  imageQuery: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['open', 'new', 'image-query-loaded'])

const store = useStore()
const lightTableRef = ref(null)
const selectedIds = ref([])
const isApplyOtuVisible = ref(false)
const { radial, radialRef, openRadial } = useRadialOpener()

const layoutItems = computed(() => store.layout?.items || [])

const placedKeys = computed(
  () =>
    new Set(
      layoutItems.value.map((it) => imageKey(it.meta.objectId))
    )
)

const selectedItems = computed(() => {
  const ids = new Set(selectedIds.value)

  return layoutItems.value.filter((it) => ids.has(it.id))
})

function addFromSource(payload, point = null) {
  const lightTable = lightTableRef.value
  const keys = new Set(placedKeys.value)
  const sources = payload.objects
    .map((object) => objectToSource(payload.objectType, object))
    .filter((s) => {
      const key = imageKey(s.meta.objectId)

      if (keys.has(key)) return false
      keys.add(key)

      return true
    })

  const skipped = payload.objects.length - sources.length

  if (skipped) {
    TW.workbench.alert.create(
      `${skipped} image(s) already on the light table.`,
      'notice'
    )
  }

  if (!sources.length) return

  const ids = lightTable.addItems(
    sources.map((source, i) => ({
      ...source,
      ...(point && {
        x: point.x + i * DROP_OFFSET,
        y: point.y + i * DROP_OFFSET
      })
    }))
  )

  lightTable.selectOnly(ids)

  return loadDepictions(ids)
}

async function loadDepictions(ids) {
  const lightTable = lightTableRef.value
  const items = ids
    .map((id) => lightTable.items.find((it) => it.id === id))
    .filter(Boolean)
  const depictionsByImage = await store.loadImageDepictions(
    items.map((it) => it.meta.objectId)
  )

  items.forEach((it) => {
    lightTable.updateItemMeta(it.id, {
      depictions: depictionsByImage.get(it.meta.objectId) || []
    })
  })
}

function onOtuApplied({ hasDeterminations }) {
  const determinedTypes = [...DETERMINABLE_TYPES, ANATOMICAL_PART]
  const ids = new Set(selectedIds.value)

  if (hasDeterminations) {
    layoutItems.value
      .filter((it) =>
        it.meta.depictions?.some((d) =>
          determinedTypes.includes(d.depiction_object_type)
        )
      )
      .forEach((it) => ids.add(it.id))
  }

  isApplyOtuVisible.value = false
  loadDepictions([...ids])
}

function openItemRadial({ type, globalId }) {
  openRadial({ component: RADIAL_COMPONENTS[type], props: { globalId } })
}

function onDrop({ point, dataTransfer }) {
  try {
    addFromSource(JSON.parse(dataTransfer.getData(DRAG_TYPE)), point)
  } catch {

  }
}

function addImagesFromQuery(params) {
  store.isLoading = true

  Image.filter({ ...params, per: MAX_FILTER_IMAGES })
    .then(({ body }) => {
      store.filterImages = body

      return addFromSource({ objectType: IMAGE, objects: body })
    })
    .catch(() => {})
    .finally(() => {
      store.isLoading = false
    })
}

onMounted(() => {
  if (props.imageQuery) {
    addImagesFromQuery(props.imageQuery)
    emit('image-query-loaded')
  }
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
  height: calc(100vh - 140px);
  min-height: 480px;
  overflow: hidden;
}

.light-table-editor__side {
  max-height: calc(100vh - 140px);
  overflow-y: auto;
}
</style>
