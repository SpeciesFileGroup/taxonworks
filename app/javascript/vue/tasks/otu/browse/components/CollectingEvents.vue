<template>
  <section-panel
    :status="status"
    :title="title"
    :spinner="isLoading">
    <ul>
      <template
        v-for="(item, index) in collectingEvents"
        :key="item.id">
        <li
          v-if="index < MAX_LIST || showAll">
          <a
            :href="`/collecting_events/${item.id}`"
            v-html="item.object_tag"/>
        </li>
      </template>
    </ul>
    <template v-if="collectingEvents.length > MAX_LIST">
      <a
        v-if="!showAll"
        class="cursor-pointer"
        @click="showAll = true">Show all
      </a>
      <a
        v-else
        class="cursor-pointer"
        @click="showAll = false">Show less
      </a>
    </template>
    <switch-component
      :options="TABS"
      v-model="view"/>
    <map-component
      width="100%"
      :zoom="2"
      :zoom-on-click="false"
      :geojson="shapes"/>
  </section-panel>
</template>

<script setup>

import SectionPanel from './shared/sectionPanel'
import MapComponent from 'components/georeferences/map.vue'
import SwitchComponent from 'components/switch.vue'
import nonReactiveStore from '../store/nonReactiveStore.js'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { computed, ref, watch } from 'vue'
import { useStore } from 'vuex'

const MAX_LIST = 10
const TABS = ['georeferences', 'asserted distributions', 'both']

const store = useStore()
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
  }
})

const georeferences = computed(() => store.getters[GetterNames.GetGeoreferences])

const descedantsGeoreferences = computed(() => store.getters[GetterNames.GetDescendants].georeferences)

const collectionObjects = computed(() => store.getters[GetterNames.GetCollectionObjects])

const isLoading = computed(() => {
  const loadState = store.getters[GetterNames.GetLoadState]

  return loadState.distribution && loadState.descendantsDistribution
})

const collectingEvents = computed({
  get () {
    return store.getters[GetterNames.GetCollectingEvents]
  },
  set (value) {
    store.commit(MutationNames.SetCollectingEvents, value)
  }
})

const assertedDistributions = computed(() => {
  const ADs = store.getters[GetterNames.GetAssertedDistributions]
  const uniqueADs = nonReactiveStore.geographicAreas

  return uniqueADs.map(shape => {
    shape.properties.is_absent = shape.is_absent

    return shape
  })
})
const shapes = computed(() => {
  switch (view.value) {
    case 'both':
      return [].concat(assertedDistributions.value, geojson.value.features)
    case 'georeferences':
      return geojson.value.features
    default:
      return assertedDistributions.value
  }
})

const showAll = ref(false)
const view = ref('both')
const geojson = ref({
  features: []
})

watch(georeferences, newVal => {
  if (newVal) {
    populateShapes()
  }
})

watch(descedantsGeoreferences, newVal => {
  if (newVal) {
    populateShapes()
  }
}, { deep: true })

const populateShapes = () => {
  const georeferencesArray = [].concat(descedantsGeoreferences.value, georeferences.value)
  geojson.value.features = []

  georeferencesArray.forEach(geo => {
    const popup = composePopup(geo)

    if (geo.error_radius != null) {
      geo.geo_json.properties.radius = geo.error_radius
    }
    if (popup) {
      geo.geo_json.properties.popup = popup
    }

    geojson.value.features.push(geo.geo_json)
  })
}

const getCollectionObjectByGeoId = georeference => collectionObjects.value.filter(co => co.collecting_event_id === getCEByGeo(georeference).id)

const composePopup = geo => {
  const ce = getCEByGeo(geo)
  if (ce) {
    return `<h4><b>Collection objects</b></h4>
      ${getCollectionObjectByGeoId(geo).map(item => `<a href="/tasks/collection_objects/browse?collection_object_id=${item.id}">${item.object_tag}</a>`).join('<br>')}
      <h4><b>Collecting event</b></h4>
      <a href="/tasks/collecting_events/browse?collecting_event_id=${ce.id}">${ce.object_tag}</a>`
  }
  return undefined
}

const getCEByGeo = georeference => collectingEvents.value.find(ce => ce.id === georeference.collecting_event_id)
</script>
