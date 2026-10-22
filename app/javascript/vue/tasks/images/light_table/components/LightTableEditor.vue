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
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { Image } from '@/routes/endpoints'
import { LightTable } from '@/components/LightTable'
import { IMAGE } from '@/constants'
import { DRAG_TYPE, LABELS } from '../constants'
import { objectToSource } from '../adapters/source'
import useStore from '../store/store'
import SaveBar from './SaveBar.vue'
import SelectionPanel from './SelectionPanel.vue'
import SourcePanel from './sources/SourcePanel.vue'
import ItemContextMenu from './ItemContextMenu.vue'
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
const { radial, radialRef, openRadial } = useRadialOpener()

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
  Image.filter({ ...params, per: MAX_FILTER_IMAGES })
    .then(({ body }) => {
      store.filterImages = body
      addFromSource({ objectType: IMAGE, objects: body })
    })
    .catch(() => {})
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
