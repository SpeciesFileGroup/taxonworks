<template>
  <SectionPanel
    :status="status"
    :title="title"
    :spinner="isLoading"
  >
    <SwitchComponent
      v-if="isSpeciesGroup"
      :options="Object.values(TABS)"
      v-model="view"
    />
    <div class="relative">
      <VMap
        width="100%"
        :zoom="2"
        :zoom-on-click="false"
        :geojson="shapes"
      />
      <CachedMap
        v-if="cachedMap"
        :cached-map="cachedMap"
      />
    </div>
  </SectionPanel>
</template>

<script setup>
import SectionPanel from './shared/sectionPanel'
import VMap from '@/components/georeferences/map.vue'
import SwitchComponent from '@/components/ui/VSwitch.vue'
import CachedMap from './CachedMap.vue'
import { GetterNames } from '../store/getters/getters'
import { computed, ref } from 'vue'
import { useStore } from 'vuex'
import {
  GEOREFERENCE,
  ASSERTED_DISTRIBUTION,
  COLLECTION_OBJECT
} from '@/constants/index.js'

const TABS = {
  Georeferences: 'Georeferences',
  AssertedDistributions: 'Asserted distributions',
  Both: 'Both'
}

const store = useStore()
defineProps({
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
  }
})

const georeferences = computed(
  () => store.getters[GetterNames.GetGeoreferences]
)
const features = computed(() => {
  const { features = [] } = georeferences.value

  return features.map((item) => addPopup(item))
})

const isSpeciesGroup = computed(() => store.getters[GetterNames.IsSpeciesGroup])

const cachedMap = computed(() => store.getters[GetterNames.GetCachedMap])

const isLoading = computed(() => {
  const loadState = store.getters[GetterNames.GetLoadState]

  return loadState.distribution
})

const shapes = computed(() => {
  switch (view.value) {
    case TABS.AssertedDistributions:
      return features.value.filter(
        (item) => item.properties.base.type === ASSERTED_DISTRIBUTION
      )
    case TABS.Georeferences:
      return features.value.filter(
        (item) => item.properties.type === GEOREFERENCE
      )
    default:
      return features.value
  }
})

const view = ref(TABS.Both)

function addPopup(georeference) {
  const popup = composePopup(georeference)

  if (popup) {
    georeference.properties.popup = popup
  }

  return georeference
}

function composePopup(geo) {
  const { id, type, label } = geo.properties.base || {}

  if (!id) {
    return
  }

  if (type === COLLECTION_OBJECT) {
    return `<a href="/tasks/collection_objects/browse?collection_object_id=${id}">${label}</a>`
  } else {
    return `<span>${label}</span>`
  }
}
</script>
