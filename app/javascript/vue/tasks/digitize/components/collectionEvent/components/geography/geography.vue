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
              :checked="areasByCoors[0].id == geographicArea"
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
        <h3 slot="header">
          Select geographic area
        </h3>
        <div slot="body">
          <ul class="no_bullets">
            <li
              class="separate-bottom"
              v-for="item in areasByCoors"
              :key="item.id"
            >
              <label>
                <input
                  type="radio"
                  :checked="item.id == geographicArea"
                  @click="selectGeographicArea(item); showModal = false"
                >
                <span v-html="item.label_html" />
              </label>
            </li>
          </ul>
        </div>
      </modal-component>
    </template>
    <template v-if="selected">
      <div class="middle separate-top">
        <span data-icon="ok" />
        <span class="separate-right"> {{ (selected['label'] ? selected.label : selected.name) }}</span>
        <span
          class="circle-button button-default btn-undo"
          @click="clearSelection"
        />
      </div>
    </template>
  </fieldset>
</template>

<script>

import SmartSelector from 'components/smartSelector.vue'
import { GetterNames } from '../../../../store/getters/getters.js'
import { MutationNames } from '../../../../store/mutations/mutations.js'
import { GeographicArea } from 'routes/endpoints'

import convertDMS from '../../../../helpers/parseDMS.js'
import ModalComponent from 'components/modal'
import refreshSmartSelector from '../../../shared/refreshSmartSelector'

export default {
  mixins: [refreshSmartSelector],
  components: {
    SmartSelector,
    ModalComponent
  },
  computed: {
    geographicArea: {
      get () {
        return this.$store.getters[GetterNames.GetCollectionEvent].geographic_area_id
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectionEventGeographicArea, value)
      }
    },
    collectingEvent () {
      return this.$store.getters[GetterNames.GetCollectionEvent]
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
          GeographicArea.find(newVal.geographic_area_id).then(response => {
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
    },
    deep: true,
    immediate: true
  },
  methods: {
    clearSelection () {
      this.selected = undefined
      this.geographicArea = null
      this.geographicAreaShape = undefined
    },
    selectGeographicArea (item) {
      this.selected = item
      this.geographicArea = item.id
    },
    getByCoords (lat, long) {
      GeographicArea.coordinates({ latitude: lat, longitude: long }).then(response => {
        this.areasByCoors = response.body
      })
    }
  }
}
</script>
