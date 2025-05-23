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
        @click="showModal = true"
      >
        Show other options
      </a>
    </div>

    <modal-component
      v-if="showModal"
      @close="showModal = false"
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
                    showModal = false
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
      v-if="geographicArea"
      :item="geographicArea"
      label="name"
      @unset="selectGeographicArea()"
    />
    <MetaPrioritizeGeographicArea
      :disabled="!geographicArea"
      v-model="collectingEvent.meta_prioritize_geographic_area"
    />
  </fieldset>
</template>

<script>
import { MutationNames } from '../../store/mutations/mutations'
import { GetterNames } from '../../store/getters/getters'
import { ActionNames } from '../../store/actions/actions'
import { GeographicArea } from '@/routes/endpoints'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import convertDMS from '@/helpers/parseDMS.js'
import ModalComponent from '@/components/ui/Modal'
import MetaPrioritizeGeographicArea from '../Meta/MetaPrioritizeGeographicArea.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import MapShapePicker from '@/components/ui/SmartSelector/MapShapePicker.vue'

import extendCE from '../mixins/extendCE'

export default {
  mixins: [extendCE],

  components: {
    SmartSelector,
    ModalComponent,
    MetaPrioritizeGeographicArea,
    SmartSelectorItem,
    MapShapePicker
  },

  computed: {
    geographicAreaId() {
      return this.collectingEvent.geographic_area_id
    },

    verbatimLatitude() {
      return this.collectingEvent.verbatim_latitude
    },

    verbatimLongitude() {
      return this.collectingEvent.verbatim_longitude
    },

    geographicArea() {
      return this.$store.getters[GetterNames.GetGeographicArea]
    },

    collectingEvent: {
      get() {
        return this.$store.getters[GetterNames.GetCollectingEvent]
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectingEvent, value)
      }
    }
  },

  data() {
    return {
      selected: undefined,
      showModal: false,
      areasByCoors: [],
      geoId: undefined,
      ajaxCall: undefined,
      delay: 1000
    }
  },

  watch: {
    geographicAreaId(newVal) {
      this.$store.dispatch(ActionNames.LoadGeographicArea, newVal)
    },

    verbatimLongitude() {
      this.getGeographicByVerbatim()
    },

    verbatimLatitude() {
      this.getGeographicByVerbatim()
    }
  },

  methods: {
    selectGeographicArea(item) {
      this.$store.dispatch(ActionNames.LoadGeographicArea, item?.id)
    },

    getByCoords(lat, long) {
      GeographicArea.coordinates({
        latitude: lat,
        longitude: long,
        embed: ['shape']
      }).then((response) => {
        this.areasByCoors = response.body
      })
    },

    getGeographicByVerbatim() {
      if (this.collectingEvent.geographic_area_id) return
      if (
        convertDMS(this.verbatimLatitude) &&
        convertDMS(this.verbatimLongitude)
      ) {
        clearTimeout(this.ajaxCall)
        this.ajaxCall = setTimeout(() => {
          this.getByCoords(
            convertDMS(this.verbatimLatitude),
            convertDMS(this.verbatimLongitude)
          )
        }, this.delay)
      }
    }
  }
}
</script>
