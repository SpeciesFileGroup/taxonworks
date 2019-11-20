<template>
  <fieldset>
    <legend>Geographic area</legend>
    <smart-selector
      class="separate-bottom item"
      name="geography"
      v-model="view"
      :add-option="moreOptions"
      :options="options"/>
    <template>
      <autocomplete
        v-if="view == 'search'"
        url="/geographic_areas/autocomplete"
        min="2"
        param="term"
        placeholder="Select a geographic area"
        @getItem="selectGeographicArea"
        display="label"
        ref="autocomplete"
        :clear-after="true"
        label="label_html"/>
      <ul
        class="no_bullets"
        v-else>
        <li
          v-for="item in lists[view]"
          :key="item.id">
          <label>
            <input
              type="radio"
              :checked="item.id == geographicArea"
              @click="selectGeographicArea(item)">
          {{ item.name }}
          </label>
        </li>
      </ul>
      <div v-if="areasByCoors.length">
        <h4>By coordinates</h4>
        <p>
          <label>
            <input
              type="radio"
              :checked="areasByCoors[0].id == geographicArea"
              @click="selectGeographicArea(areasByCoors[0])">
            <span v-html="areasByCoors[0].label_html"/>
          </label>
        </p>
        <a 
          v-if="areasByCoors.length > 1"
          class="cursor-pointer"
          @click="showModal = true">
          Show other options
        </a>
      </div>

      <modal-component 
        v-if="showModal"
        @close="showModal = false">
        <h3 slot="header">Select geographic area</h3>
        <div slot="body">
          <ul class="no_bullets">
            <li
              class="separate-bottom"
              v-for="item in areasByCoors"
              :key="item.id">
              <label>
                <input
                  type="radio"
                  :checked="item.id == geographicArea"
                  @click="selectGeographicArea(item); showModal = false">
                <span v-html="item.label_html"/>
              </label>
            </li>
          </ul>
        </div>
      </modal-component>

    </template>
    <template v-if="selected">
      <div class="middle separate-top">
        <span data-icon="ok"/>
        <span class="separate-right"> {{ (selected['label'] ? selected.label : selected.name) }}</span>
        <span
          class="circle-button button-default btn-undo"
          @click="clearSelection"/>
      </div>
    </template>
  </fieldset>
</template>

<script>

  import Autocomplete from 'components/autocomplete'
  import SmartSelector from 'components/switch.vue'
  import { GetterNames } from '../../../../store/getters/getters.js'
  import { MutationNames } from '../../../../store/mutations/mutations.js'
  import { GetGeographicSmartSelector, GetGeographicAreaByCoords } from '../../../../request/resources.js'
  import OrderSmartSelector from 'helpers/smartSelector/orderSmartSelector'
  import convertDMS from '../../../../helpers/parseDMS.js'
  import ModalComponent from 'components/modal'

  export default {
    components: {
      SmartSelector,
      Autocomplete,
      ModalComponent
    },
    computed: {
      geographicArea: {
        get() {
          return this.$store.getters[GetterNames.GetCollectionEvent].geographic_area_id
        },
        set(value) {
          this.$store.commit(MutationNames.SetCollectionEventGeographicArea, value)
        }
      },
      collectingEvent() {
        return this.$store.getters[GetterNames.GetCollectionEvent]
      }
    },
    data() {
      return {
        moreOptions: ['search'],
        options: [],
        view: 'search',
        lists: [],
        selected: undefined,
        showModal: false,
        delay: 1000,
        areasByCoors: [],
        ajaxCall: undefined
      }
    },
    watch: {
      collectingEvent: {
        handler(newVal, oldVal) {
          if(convertDMS(newVal.verbatim_latitude) && convertDMS(newVal.verbatim_longitude)) {
            let that = this
            clearTimeout(this.ajaxCall)
            this.ajaxCall = setTimeout(() => { that.getByCoords(convertDMS(newVal.verbatim_latitude), convertDMS(newVal.verbatim_longitude)) }, this.delay)
          }
        },
        deep: true
      }
    },
    mounted () {
      this.GetSmartSelector()
    },
    methods: {
      clearSelection() {
        this.selected = undefined
        this.geographicArea = undefined
      },
      GetSmartSelector() {
        GetGeographicSmartSelector().then(response => {
          let result = response
          this.options = OrderSmartSelector(Object.keys(result))
          this.lists = response        
        })
      },
      selectGeographicArea(item) {
        this.selected = item
        this.geographicArea = item.id
      },
      getByCoords(lat, long) {
        GetGeographicAreaByCoords(lat, long).then(response => {
          this.areasByCoors = response
        })
      }
    }
  }
</script>
