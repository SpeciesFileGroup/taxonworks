<template>
  <PanelLayout
    :status="status"
    :title="title"
    :spinner="isLoading"
    :empty="!geojson.length && !cachedMap"
    :skeleton="{
      variant: 'rect',
      height: '398px'
    }"
  >
    <div
      ref="mapContainerElement"
      class="relative distribution-map"
      :class="{ 'distribution-map--fullscreen': isFullscreen }"
    >
      <div :class="['relative', { 'h-full': isFullscreen }]">
        <VMap
          ref="mapComponent"
          width="100%"
          :height="isFullscreen ? '100%' : '332px'"
          cluster
          :zoom="2"
          :zoom-on-click="false"
          :geojson="shapes"
          :cluster-icon-create-function="makeClusterIconFor"
        />
        <CachedMap
          v-if="cachedMap"
          :cached-map="cachedMap"
        />
      </div>
      <div
        class="absolute distribution-map__fullscreen"
        :class="{ 'distribution-map__fullscreen--shifted': !!cachedMap }"
      >
        <VBtn
          circle
          class="leaflet-map-button"
          :title="isFullscreen ? 'Exit full screen' : 'Full screen'"
          @click="toggleFullscreen"
        >
          <VIcon
            :name="isFullscreen ? 'contract' : 'expand'"
            x-small
          />
        </VBtn>
      </div>
      <DistributionLegend :shape-types="shapeTypes" />
    </div>
  </PanelLayout>
</template>

<script setup>
import PanelLayout from '../PanelLayout.vue'
import VMap from '@/components/ui/VMap/VMap.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import CachedMap from './CachedMap.vue'
import DistributionLegend from './DistributionLegend.vue'
import { makeClusterIconFor } from '@/components/ui/VMap/clusters'
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { GEOREFERENCE, ASSERTED_DISTRIBUTION, OTU } from '@/constants/index.js'
import useDistribution from './composables/useDistribution.js'

const TABS = {
  Georeferences: 'Georeferences',
  AssertedDistributions: 'Asserted distributions',
  Both: 'Both'
}

const props = defineProps({
  status: {
    type: String,
    default: 'unknown'
  },

  title: {
    type: String,
    default: undefined
  },

  otu: {
    type: Object,
    required: true
  },

  otus: {
    type: Array,
    required: true
  },

  taxonName: {
    type: String,
    required: true
  }
})

const {
  geojson,
  isLoading,
  cachedMap,
  shapeTypes,
  isAggregateMap,
  loadMapData
} = useDistribution()

const shapes = computed(() => {
  const otuIds = new Set(props.otus.map((o) => o.id))

  const matchesOTU = (item) =>
    item.properties.target.some((t) => t.type === OTU && otuIds.has(t.id))

  const matchesBase = (item, type) =>
    item.properties.base.some((b) => b.type === type)

  let baseType

  switch (view.value) {
    case TABS.AssertedDistributions:
      baseType = ASSERTED_DISTRIBUTION
      break
    case TABS.Georeferences:
      baseType = GEOREFERENCE
      break
  }

  return isAggregateMap.value
    ? geojson.value
    : geojson.value.filter((item) => {
        if (!matchesOTU(item)) return false
        if (!baseType) return true

        return matchesBase(item, baseType)
      })
})

const view = ref(TABS.Both)

const mapContainerElement = ref(null)
const mapComponent = ref(null)
const isFullscreen = ref(false)

async function toggleFullscreen() {
  if (isFullscreen.value) {
    if (document.fullscreenElement) {
      await document.exitFullscreen()
    }

    isFullscreen.value = false
  } else {
    try {
      await mapContainerElement.value.requestFullscreen()
    } catch {}

    isFullscreen.value = true
  }

  await refreshMapSize()
}

async function refreshMapSize() {
  await nextTick()
  mapComponent.value?.getMapObject()?.invalidateSize()
}

function syncFullscreen() {
  if (!document.fullscreenElement && isFullscreen.value) {
    isFullscreen.value = false
    refreshMapSize()
  }
}

function exitFullscreenOnEscape(event) {
  if (event.key === 'Escape' && isFullscreen.value) {
    toggleFullscreen()
  }
}

onMounted(() => {
  document.addEventListener('fullscreenchange', syncFullscreen)
  document.addEventListener('keydown', exitFullscreenOnEscape)
})

onBeforeUnmount(() => {
  document.removeEventListener('fullscreenchange', syncFullscreen)
  document.removeEventListener('keydown', exitFullscreenOnEscape)
})

watch(
  () => props.otu,
  async (newOtu) => {
    if (newOtu) {
      await loadMapData(newOtu.id, props.taxonName?.rank_string)
    }
  },
  { immediate: true }
)
</script>

<style lang="scss" scoped>
:deep(.body) {
  padding: 0px !important;
}

.distribution-map__fullscreen {
  top: 12px;
  right: 12px;
  z-index: 1000;
}

.distribution-map--fullscreen {
  position: fixed;
  inset: 0;
  z-index: 3000;
  display: flex;
  flex-direction: column;
  background-color: var(--bg-color);

  :deep(.vue-leaflet) {
    flex: 1 1 auto;
    min-height: 0;
  }
}
</style>
