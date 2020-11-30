<template>
  <section-panel
    :status="status"
    :title="title"
    :spinner="isLoading">
    <ul>
      <li
        v-for="(item, index) in collectingEvents"
        :key="item.id"
        v-if="index < max || showAll">
        <a
          :href="`/collecting_events/${item.id}`"
          v-html="item.object_tag"/>
      </li>
    </ul>
    <template v-if="collectingEvents.length > max">
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
      :options="tabs"
      v-model="view"/>
    <map-component
      width="100%"
      :zoom="2"
      :zoom-on-click="false"
      :geojson="shapes"/>
  </section-panel>
</template>

<script>

import SectionPanel from './shared/sectionPanel'
import MapComponent from 'components/georeferences/map.vue'
import SwitchComponent from 'components/switch.vue'
import extendSection from './shared/extendSections'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'

export default {
  mixins: [extendSection],
  components: {
    SectionPanel,
    MapComponent,
    SwitchComponent
  },
  computed: {
    isLoading () {
      return this.$store.getters[GetterNames.GetLoadState].distribution
    },
    collectingEvents: {
      get () {
        return this.$store.getters[GetterNames.GetCollectingEvents]
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectingEvents, value)
      }
    },
    georeferences () {
      return this.$store.getters[GetterNames.GetGeoreferences]
    },
    descedantsGeoreferences () {
      return this.$store.getters[GetterNames.GetDescendants].georeferences
    },
    collectionObjects () {
      return this.$store.getters[GetterNames.GetCollectionObjects]
    },
    assertedDistributions () {
      const ADs = this.$store.getters[GetterNames.GetAssertedDistributions]
      return ADs.map(item => { 
        let shape = item.geographic_area.shape
        shape.properties.is_absent = item.is_absent

        return shape
      })
    },
    shapes () {
      switch (this.view) {
        case 'both':
          return [].concat(this.assertedDistributions, this.geojson.features)
        case 'georeferences':
          return this.geojson.features
        default:
          return this.assertedDistributions
      }
    }
  },
  data () {
    return {
      max: 10,
      showAll: false,
      tabs: ['georeferences', 'asserted distributions', 'both'],
      view: 'both',
      geojson: {
        features: []
      }
    }
  },
  watch: {
    georeferences: {
      handler (newVal) {
        if (newVal) {
          this.populateShapes()
        }
      }
    },
    descedantsGeoreferences: {
      handler (newVal) {
        if (newVal) {
          this.populateShapes()
        }
      },
      deep: true
    }
  },
  methods: {
    populateShapes () {
      const georeferences = [].concat(this.descedantsGeoreferences, this.georeferences)
      this.geojson.features = []

      georeferences.forEach(geo => {
        const popup = this.composePopup(geo)
        if (geo.error_radius != null) {
          geo.geo_json.properties.radius = geo.error_radius
        }
        if (popup) {
          geo.geo_json.properties.popup = popup
        }
        this.geojson.features.push(geo.geo_json)
      })
    },
    getCollectionObjectByGeoId (georeference) {

      return this.collectionObjects.filter(co => { return co.collecting_event_id === this.getCEByGeo(georeference).id })
    },
    composePopup (geo) {
      const ce = this.getCEByGeo(geo)
      if (ce) {
        return `<h4><b>Collection objects</b></h4>
          ${this.getCollectionObjectByGeoId(geo).map(item => `<a href="/tasks/collection_objects/browse?collection_object_id=${item.id}">${item.object_tag}</a>`).join('<br>')}
          <h4><b>Collecting event</b></h4>
          <a href="/tasks/collecting_events/browse?collecting_event_id=${ce.id}">${ce.object_tag}</a>`
      }
      return undefined
    },
    getCEByGeo (georeference) {
      return this.collectingEvents.find(ce => { return ce.id === georeference.collecting_event_id })
    }
  }
}
</script>