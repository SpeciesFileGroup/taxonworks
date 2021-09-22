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
                @click="selectGeographicArea(item); showModal = false"
              >
              <span v-html="item.label_html" />
            </label>
          </li>
        </ul>
      </template>
    </modal-component>
    <template v-if="selected">
      <hr>
      <div class="middle flex-separate">
        <p>
          <span data-icon="ok" />
          <span class="separate-right"> {{ (selected['label'] ? selected.label : selected.name) }}</span>
        </p>
        <span
          class="circle-button button-default btn-undo"
          @click="clearSelection"
        />
      </div>
    </template>
  </fieldset>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector.vue'
import { GetterNames } from '../../../../store/getters/getters.js'
import { MutationNames } from '../../../../store/mutations/mutations.js'
import { GeographicArea } from 'routes/endpoints'

import convertDMS from 'helpers/parseDMS.js'
import ModalComponent from 'components/ui/Modal'
import extendCE from '../../mixins/extendCE.js'

export default {
  mixins: [extendCE],

  components: {
    SmartSelector,
    ModalComponent
  },

  computed: {
    collectingEvent () {
      return this.$store.getters[GetterNames.GetCollectingEvent]
    },

    geographicAreaShape: {
      get () {
        return this.$store.getters[GetterNames.GetGeographicArea]
      },
      set (value) {
        this.$store.commit(MutationNames.SetGeographicArea, value)
      }
    }
  },

  data () {
    return {
      moreOptions: ['search'],
      options: [],
      view: 'search',
      lists: [],
      selected: undefined,
      showModal: false,
      delay: 1000,
      areasByCoors: [],
      ajaxCall: undefined,
      geoId: undefined
    }
  },

  watch: {
    collectingEvent: {
      handler (newVal) {
        if (this.geoId && newVal && newVal.geographic_area_id === this.geoId) return
        this.geoId = newVal.geographic_area_id
        if (newVal.geographic_area_id) {
          GeographicArea.find(newVal.geographic_area_id, { embed: ['shape'] }).then(response => {
            this.selectGeographicArea(response.body)
            this.geographicAreaShape = response.body
          })
        } else {
          this.selected = undefined
          if (convertDMS(newVal.verbatim_latitude) && convertDMS(newVal.verbatim_longitude)) {
            clearTimeout(this.ajaxCall)
            this.ajaxCall = setTimeout(() => {
              this.getByCoords(convertDMS(newVal.verbatim_latitude), convertDMS(newVal.verbatim_longitude))
            }, this.delay)
          }
        }
      }
    }
  },

  methods: {
    clearSelection () {
      this.selected = undefined
      this.collectingEvent.geographic_area_id = null
      this.geographicAreaShape = undefined
    },
    selectGeographicArea (item) {
      this.selected = item
      this.collectingEvent.geographic_area_id = item.id
    },
    getByCoords (lat, long) {
      GeographicArea.coordinates({ latitude: lat, longitude: long }).then(response => {
        this.areasByCoors = response.body
      })
    }
  }
}
</script>
