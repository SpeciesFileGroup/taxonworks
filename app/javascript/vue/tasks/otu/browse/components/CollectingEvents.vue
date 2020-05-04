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
        :geojson="geojson.features"/>
    </template>
  </section-panel>
</template>

<script>

import SectionPanel from './shared/sectionPanel'
import { GetCollectingEvents, GetGeoreferences } from '../request/resources.js'
import MapComponent from 'components/georeferences/map.vue'

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
  data () {
    return {
      collectingEvents: [],
      max: 10,
      showAll: false,
      geojson: {
        features: []
      },
      georeferences: []
    }
  },
  watch: {
    otu: {
      handler (newVal) {
        GetCollectingEvents([this.otu.id]).then(response => {
          let promises = []

          this.collectingEvents = response.body
          this.collectingEvents.forEach(ce => {
            promises.push(GetGeoreferences(ce.id).then(response => {
              this.georeferences = this.georeferences.concat(response.body)
            }))
          })

          Promise.all(promises).then(() => {
            this.populateShapes()
          })
        })
      },
      immediate: true
    }
  },
  methods: {
    populateShapes() {
      this.geojson.features = []
      this.georeferences.forEach(geo => {
        if (geo.error_radius != null) {
          geo.geo_json.properties.radius = geo.error_radius
        }
        this.geojson.features.push(geo.geo_json)
      })
    },
  }
}
</script>