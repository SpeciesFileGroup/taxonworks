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
        <a
          v-if="areasByCoors.length > 1"
          class="cursor-pointer"
          @click="showModal = true"
        >
          Show other options
        </a>
      </p>
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
            class="margin-small-bottom"
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
    <hr v-if="selected">
    <SmartSelectorItem
      v-if="selected"
      :item="selected"
      label="name"
      @unset="clearSelection"
    />
    <MetaPrioritizeGeographicArea
      v-model="collectingEvent.meta_prioritize_geographic_area"
      :disabled="!geographicAreaShape"
    />
  </fieldset>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector.vue'
import SmartSelectorItem from 'components/ui/SmartSelectorItem.vue'
import MetaPrioritizeGeographicArea from 'tasks/collecting_events/new_collecting_event/components/Meta/MetaPrioritizeGeographicArea.vue'
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
    ModalComponent,
    SmartSelectorItem,
    MetaPrioritizeGeographicArea
  },

  computed: {
    collectingEvent: {
      get () {
        return this.$store.getters[GetterNames.GetCollectingEvent]
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectingEvent, value)
      }
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
      },
      deep: true
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
