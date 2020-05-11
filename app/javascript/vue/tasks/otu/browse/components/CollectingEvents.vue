<template>
  <section-panel title="Collecting events">
    <a name="collecting-events"/>
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
    <template v-if="geojson.features.length">
      <h4>Georeferences</h4>
      <map-component
        width="100%"
        :zoom-on-click="false"
        :geojson="geojson.features"/>
    </template>
  </section-panel>
</template>

<script>

import SectionPanel from './shared/sectionPanel'
import MapComponent from 'components/georeferences/map.vue'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'

export default {
  components: {
    SectionPanel,
    MapComponent
  },
  props: {
    otu: {
      type: Object
    }
  },
  computed: {
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
    collectionObjects () {
      return this.$store.getters[GetterNames.GetCollectionObjects]
    }
  },
  data () {
    return {
      max: 10,
      showAll: false,
      geojson: {
        features: []
      }
    }
  },
  watch: {
    georeferences: {
      handler (newVal) {
        if (newVal)
          this.populateShapes()
      }
    }
  },
  methods: {
    populateShapes () {
      this.geojson.features = []
      this.georeferences.forEach(geo => {
        if (geo.error_radius != null) {
          geo.geo_json.properties.radius = geo.error_radius
        }
        geo.geo_json.properties.popup = `${this.composePopup(geo)}`
        this.geojson.features.push(geo.geo_json)

      })
    },
    getCollectionObjectByGeoId (georeference) {

      return this.collectionObjects.filter(co => { return co.collecting_event_id === this.getCEByGeo(georeference).id })
    },
    composePopup (geo) {
      const ce = this.getCEByGeo(geo)
      return `<h4><b>Collection objects</b></h4>
        ${this.getCollectionObjectByGeoId(geo).map(item => `<a href="/tasks/collection_objects/browse?collection_object_id=${item.id}">${item.object_tag}</a>`).join('<br>')}
        <h4><b>Collecting event</b></h4>
        <a href="/tasks/collecting_events/browse?collecting_event_id=${ce.id}">${ce.object_tag}</a>`
    },
    getCEByGeo (georeference) {
      return this.collectingEvents.find(ce => { return ce.id === georeference.collecting_event_id })
    }
  }
}
</script>