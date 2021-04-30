<template>
  <div>
    <h3>Geographic area</h3>
    <switch-component
      class="separate-bottom"
      v-model="view"
      :options="tabs"/>
    <div v-if="view === 'area'">
      <div class="field">
        <autocomplete
          url="/geographic_areas/autocomplete"
          label="label_html"
          :clear-after="true"
          placeholder="Search a geographic area"
          param="term"
          @getItem="addGeoArea($event.id)"/>
      </div>
      <label>
        <input
          v-model="geographic.spatial_geographic_areas"
          type="checkbox"/>
        Treat geographic areas as spatial
      </label>
      <div class="field separate-top">
        <ul class="no_bullets table-entrys-list">
          <li
            class="middle flex-separate list-complete-item"
            v-for="(geoArea, index) in geographic_areas"
            :key="geoArea.id">
            <span v-html="geoArea.name"/>
            <span
              class="btn-delete button-circle"
              @click="removeGeoArea(index)"/>
          </li>
        </ul>
      </div>
    </div>
    <div v-else>
      <georeference-map
        width="330px"
        height="300px"
        ref="leaflet"
        :geojson="geojson"
        @geojson="geojson = $event"
        :draw-controls="true"
        :draw-polyline="false"
        :draw-marker="false"
        :drag-mode="false"
        :cut-polygon="false"
        :draw-circle-marker="false"
        :tiles-selection="false"
        :edit-mode="false"
        :zoom="1"
        :tooltips="false"
        @geoJsonLayerCreated="addShape"
      />
    </div>
  </div>
</template>

<script>

import SwitchComponent from 'components/switch'
import Autocomplete from 'components/autocomplete'
import GeoreferenceMap from 'components/georeferences/map'
import { GetGeographicArea } from '../../request/resources'
import { URLParamsToJSON } from 'helpers/url/parse.js'

export default {
  components: {
    SwitchComponent,
    Autocomplete,
    GeoreferenceMap
  },
  props: {
    value: {
      type: Object,
      required: true
    }
  },
  computed: {
    geographic: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },
  data () {
    return {
      view: 'area',
      tabs: ['area', 'map'],
      geographic_areas: [],
      geojson: []
    }
  },
  watch: {
    geojson: {
      handler (newVal) {
        if (newVal.length) {
          this.geographic.geographic_area_ids = []
          if (newVal[0].properties && newVal[0].properties?.radius) {
            this.geographic.radius = newVal[0].properties.radius
            this.geographic.geo_json = JSON.stringify({ type: 'Point', coordinates: newVal[0].geometry.coordinates })
          } else {
            this.geographic.geo_json = JSON.stringify({ type: 'MultiPolygon', coordinates: newVal.map(feature => feature.geometry.coordinates) })
            this.geographic.radius = undefined
          }
        } else {
          this.geographic.geo_json = []
        }
      },
      deep: true
    },
    geographic: {
      handler (newVal, oldVal) {
        if (!newVal?.geo_json?.length && oldVal?.geo_json?.length) {
          this.geojson = []
        }
        if (!newVal.geographic_area_ids.length) {
          this.geographic_areas = []
        }
      },
      deep: true
    }
  },
  mounted () {
    const urlParams = URLParamsToJSON(location.href)
    if (Object.keys(urlParams).length) {
      if (urlParams.geographic_area_ids) {
        urlParams.geographic_area_ids.forEach(id => {
          this.addGeoArea(id)
        })
      }
      if (urlParams.geo_json) {
        this.addShape(this.convertGeoJSONParam(urlParams))
      }
      this.geographic.spatial_geographic_areas = urlParams.spatial_geographic_areas
    }
  },
  methods: {
    addShape (shape) {
      this.geojson = [shape]
    },
    removeGeoArea (index) {
      this.geographic.geographic_area_ids.splice(index, 1)
      this.geographic_areas.splice(index, 1)
    },
    addGeoArea (id) {
      GetGeographicArea(id).then(response => {
        this.geographic.geo_json = undefined
        this.geographic.radius = undefined
        this.geographic.geographic_area_ids.push(id)
        this.geographic_areas.push(response.body)
      })
    },
    convertGeoJSONParam (urlParams) {
      const geojson = urlParams.geo_json
      return {
        type: 'Feature',
        geometry: {
          coordinates: geojson.type === 'Point' ? geojson.coordinates : geojson.coordinates[0],
          type: geojson.type === 'Point' ? 'Point' : 'Polygon'
        },
        properties: {
          radius: urlParams?.radius
        }
      }
    }
  }
}
</script>
<style scoped>
  ::v-deep .vue-autocomplete-input {
    width: 100%
  }
</style>
