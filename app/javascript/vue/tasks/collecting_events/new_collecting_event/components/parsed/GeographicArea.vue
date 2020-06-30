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
                  :checked="item.id == collectingEvent.geographic_area_id"
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
import { GetGeographicAreaByCoords } from '../../request/resources.js'

import ModalComponent from 'components/modal'

import extendCE from '../mixins/extendCE'

export default {
  mixins: [extendCE],
  components: {
    SmartSelector,
    ModalComponent
  },
  data () {
    return {
      selected: undefined,
      showModal: false,
      areasByCoors: [],
      geoId: undefined,
      geographicArea: undefined
    }
  },
  methods: {
    clearSelection () {
      this.selected = undefined
      this.collectingEvent.geographic_area_id = null
    },
    selectGeographicArea (item) {
      this.selected = item
      this.collectingEvent.geographic_area_id = item.id
    },
    getByCoords (lat, long) {
      GetGeographicAreaByCoords(lat, long).then(response => {
        this.areasByCoors = response.body
      })
    }
  }
}
</script>
