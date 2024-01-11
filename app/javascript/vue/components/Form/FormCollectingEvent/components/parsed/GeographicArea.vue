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
        <GeographicAreaMapPicker @select="selectGeographicArea" />
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

    <modal-component
      v-if="isModalVisible"
      @close="isModalVisible = false"
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
    </modal-component>
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
import ModalComponent from '@/components/ui/Modal'
import MetaPrioritizeGeographicArea from '../Meta/MetaPrioritizeGeographicArea.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import GeographicAreaMapPicker from '@/components/ui/SmartSelector/GeographicAreaMapPicker.vue'
import useStore from '../../store/collectingEvent.js'

const DELAY = 1000
const collectingEvent = defineModel()
const store = useStore()
const isModalVisible = ref(false)
const areasByCoors = ref([])
let ajaxCall = null

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
  store.loadGeographicArea(item?.id)
}

function getByCoords(lat, long) {
  GeographicArea.coordinates({
    latitude: lat,
    longitude: long,
    embed: ['shape']
  }).then(({ body }) => {
    areasByCoors.value = body
  })
}

function getGeographicByVerbatim() {
  if (collectingEvent.value.geographic_area_id) return
  if (
    convertDMS(verbatimLatitude.value) &&
    convertDMS(verbatimLongitude.value)
  ) {
    clearTimeout(ajaxCall)
    ajaxCall = setTimeout(() => {
      getByCoords(
        convertDMS(verbatimLatitude.value),
        convertDMS(verbatimLongitude.value)
      )
    }, DELAY)
  }
}
</script>
