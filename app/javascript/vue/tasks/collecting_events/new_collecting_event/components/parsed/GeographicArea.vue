<template>
  <fieldset>
    <legend>Geographic area</legend>
    <smart-selector
      ref="smartSelector"
      model="geographic_areas"
      target="CollectingEvent"
      label="name"
      klass="CollectingEvent"
      @selected="selectGeographicArea"
    />
    <template>
      <div v-if="areasByCoors.length">
        <h4>By coordinates</h4>
        <p>
          <label>
            <input
              type="radio"
              :checked="areasByCoors[0].id == collectingEvent.geographic_area_id"
              @click="selectGeographicArea(areasByCoors[0])"
            >
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
          <h3>
            Select geographic area
          </h3>
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
                  @click="selectGeographicArea(item); showModal = false"
                >
                <span v-html="item.label_html" />
              </label>
            </li>
          </ul>
        </template>
      </modal-component>
    </template>
    <template v-if="geographicArea">
      <div class="middle separate-top">
        <span data-icon="ok" />
        <span class="separate-right"> {{ geographicArea.name }}</span>
        <span
          class="circle-button button-default btn-undo"
          @click="selectGeographicArea()"
        />
      </div>
    </template>
  </fieldset>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { ActionNames } from '../../store/actions/actions'
import { GeographicArea } from 'routes/endpoints'
import SmartSelector from 'components/ui/SmartSelector.vue'
import convertDMS from 'helpers/parseDMS.js'
import ModalComponent from 'components/ui/Modal'

import extendCE from '../mixins/extendCE'

export default {
  mixins: [extendCE],

  components: {
    SmartSelector,
    ModalComponent
  },

  computed: {
    geographicAreaId () {
      return this.collectingEvent.geographic_area_id
    },

    verbatimLatitude () {
      return this.collectingEvent.verbatim_latitude
    },

    verbatimLongitude () {
      return this.collectingEvent.verbatim_longitude
    },

    geographicArea () {
      return this.$store.getters[GetterNames.GetGeographicArea]
    }
  },

  data () {
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
    geographicAreaId (newVal) {
      this.$store.dispatch(ActionNames.LoadGeographicArea, newVal)
    },

    verbatimLongitude () {
      this.getGeographicByVerbatim()
    },

    verbatimLatitude () {
      this.getGeographicByVerbatim()
    }
  },

  methods: {
    selectGeographicArea (item) {
      this.$store.dispatch(ActionNames.LoadGeographicArea, item?.id)
    },

    getByCoords (lat, long) {
      GeographicArea.coordinates({ latitude: lat, longitude: long, geo_json: true }).then(response => {
        this.areasByCoors = response.body
      })
    },

    getGeographicByVerbatim () {
      if (this.collectingEvent.geographic_area_id) return
      if (convertDMS(this.verbatimLatitude) && convertDMS(this.verbatimLongitude)) {
        clearTimeout(this.ajaxCall)
        this.ajaxCall = setTimeout(() => { this.getByCoords(convertDMS(this.verbatimLatitude), convertDMS(this.verbatimLongitude)) }, this.delay)
      }
    }
  }
}
</script>
