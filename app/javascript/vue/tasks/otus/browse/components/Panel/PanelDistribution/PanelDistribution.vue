<template>
  <PanelLayout
    :status="status"
    :title="title"
    :spinner="isLoading"
  >
    <SwitchComponent
      :options="Object.values(TABS)"
      v-model="view"
    />
    <div class="relative">
      <VMap
        width="100%"
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
    <DistributionLegend :shape-types="shapeTypes" />
  </PanelLayout>
</template>

<script setup>
import PanelLayout from '../PanelLayout.vue'
import VMap from '@/components/ui/VMap/VMap.vue'
import SwitchComponent from '@/components/ui/VSwitch.vue'
import CachedMap from './CachedMap.vue'
import DistributionLegend from './DistributionLegend.vue'
import { makeClusterIconFor } from '@/components/ui/VMap/clusters'
import { computed, ref, watch } from 'vue'
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

watch(
  () => props.otu,
  (newOtu) => {
    if (newOtu) {
      loadMapData(newOtu.id, props.taxonName?.rank_string)
    }
  },
  { immediate: true }
)
</script>
