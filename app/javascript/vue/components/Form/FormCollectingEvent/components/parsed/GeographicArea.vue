<template>
  <fieldset>
    <legend>Geographic area</legend>
    <SmartSelector
      ref="smartSelector"
      model="geographic_areas"
      target="CollectingEvent"
      label="name"
      :add-tabs="['map']"
      klass="CollectingEvent"
      @selected="selectGeographicArea"
    >
      <template #map>
        <MapShapePicker @select="selectGeographicArea" />
      </template>
    </SmartSelector>
    <div v-if="areasByCoors.length">
      <h4>By coordinates</h4>
      <p>
        <label>
          <input
            type="radio"
            :checked="areasByCoors[0].id == collectingEvent.geographic_area_id"
            @click="selectGeographicArea(areasByCoors[0])"
          />
          <span v-html="areasByCoors[0].label_html" />
        </label>
      </p>
      <a
        v-if="areasByCoors.length > 1"
        class="cursor-pointer"
        @click="isModalVisible = true"
      >
        Show other options
      </a>
    </div>

    <VModal
      v-if="isModalVisible"
      @close="isModalVisible = false"
      :container-style="{ width: '700px' }"
    >
      <template #header>
        <h3>Select geographic area</h3>
      </template>
      <template #body>
        <ul class="no_bullets">
          <li
            class="separate-bottom"
            v-for="item in areasByCoors"
            :key="item.id"
          >
            <label>
              <input
                type="radio"
                :checked="item.id == collectingEvent.geographic_area_id"
                @click="
                  () => {
                    selectGeographicArea(item)
                    isModalVisible = false
                  }
                "
              />
              <span v-html="item.label_html" />
            </label>
          </li>
        </ul>
      </template>
    </VModal>
    <SmartSelectorItem
      v-if="store.geographicArea"
      :item="store.geographicArea"
      label="name"
      @unset="selectGeographicArea()"
    />
    <MetaPrioritizeGeographicArea
      :disabled="!store.geographicArea"
      v-model="collectingEvent.meta_prioritize_geographic_area"
    />
  </fieldset>
</template>

<script setup>
import { watch, ref, computed } from 'vue'
import { GeographicArea } from '@/routes/endpoints'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import convertDMS from '@/helpers/parseDMS.js'
import VModal from '@/components/ui/Modal'
import MetaPrioritizeGeographicArea from '../Meta/MetaPrioritizeGeographicArea.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import MapShapePicker from '@/components/ui/SmartSelector/MapShapePicker.vue'
import useStore from '../../store/collectingEvent.js'

const DELAY = 1000
const collectingEvent = defineModel({ type: Object, required: true })
const store = useStore()
const isModalVisible = ref(false)
const areasByCoors = ref([])
let timeout = null
let controller = null

const verbatimLatitude = computed(() => collectingEvent.value.verbatim_latitude)
const verbatimLongitude = computed(
  () => collectingEvent.value.verbatim_longitude
)

watch(
  () => collectingEvent.value.geographic_area_id,
  (newVal) => {
    store.loadGeographicArea(newVal)
  }
)

watch([verbatimLatitude, verbatimLongitude], () => {
  getGeographicByVerbatim()
})

function selectGeographicArea(item) {
  collectingEvent.value.isUnsaved = true
  store.loadGeographicArea(item?.id)
}

function getByCoords(lat, long) {
  controller = new AbortController()
  GeographicArea.coordinates(
    {
      latitude: lat,
      longitude: long,
      embed: ['shape']
    },
    {
      signal: controller.signal
    }
  )
    .then(({ body }) => {
      areasByCoors.value = body
    })
    .catch(() => {})
}

function getGeographicByVerbatim() {
  if (collectingEvent.value.geographic_area_id) return

  controller?.abort()
  clearTimeout(timeout)

  if (
    convertDMS(verbatimLatitude.value) &&
    convertDMS(verbatimLongitude.value)
  ) {
    timeout = setTimeout(() => {
      getByCoords(
        convertDMS(verbatimLatitude.value),
        convertDMS(verbatimLongitude.value)
      )
    }, DELAY)
  } else {
    areasByCoors.value = []
  }
}
</script>
