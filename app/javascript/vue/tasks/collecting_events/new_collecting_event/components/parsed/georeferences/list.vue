<template>
  <div class="vue-table-container">
    <table class="vue-table">
      <thead>
        <tr>
          <th class="word-keep-all line-nowrap">Georeference ID</th>
          <th class="word-keep-all">Shape</th>
          <th class="word-keep-all">Coordinates</th>
          <th class="word-keep-all line-nowrap">Error radius</th>
          <th class="word-keep-all">Type</th>
          <th></th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="item in list"
          :key="item.id"
          class="list-complete-item">
          <td>{{ item.id }}</td>
          <td class="word-keep-all">{{ isTmpWkt(item) || isTempGeolocate(item) ? '' : getGeoJsonType(item) }}</td>
          <td>{{ getCoordinatesByType(item) }}</td>
          <td class="line-nowrap">
            <edit-in-place
              v-model="item.error_radius"
              @end="$emit('updateGeo', item)"/>
          </td>
          <td class="word-keep-all">{{ item.type }}</td>
          <td class="vue-table-options">
            <radial-annotator
              v-if="item.global_id"
              :global-id="item.global_id"/>
            <span
              v-if="destroy"
              class="circle-button btn-delete"
              @click="deleteItem(item)">Remove
            </span>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
<script>

import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import EditInPlace from 'components/editInPlace'
import GeoreferenceTypes from '../../../const/georeferenceTypes'

export default {
  components: {
    RadialAnnotator,
    EditInPlace
  },
  props: {
    list: {
      type: Array,
      default: () => {
        return []
      }
    },
    header: {
      type: Array,
      default: () => {
        return []
      }
    },
    destroy: {
      type: Boolean,
      default: true
    },
    deleteWarning: {
      type: Boolean,
      default: true
    },
    annotator: {
      type: Boolean,
      default: true
    },
    edit: {
      type: Boolean,
      default: false
    }
  },
  mounted () {
    this.$options.components['RadialAnnotator'] = RadialAnnotator
  },
  methods: {
    deleteItem (item) {
      if (this.deleteWarning) {
        if (window.confirm(`You're trying to delete this record. Are you sure want to proceed?`)) {
          this.$emit('delete', item)
        }
      } else {
        this.$emit('delete', item)
      }
    },
    getCoordinates (coordinates) {
      return coordinates.map(coordinate => Array.isArray(coordinate) ? coordinate.map(item => item.slice(0, 2)) : coordinate)
    },
    geojsonObject (object) {
      return object.geo_json ? object.geo_json : JSON.parse(object.geographic_item_attributes.shape)
    },
    getGeoJsonType (object) {
      return this.geojsonObject(object).geometry.type
    },
    isTmpWkt (object) {
      return object.type === GeoreferenceTypes.Wkt && object.tmpId
    },
    isTempGeolocate (object) {
      return object.type === GeoreferenceTypes.Geolocate && object.tmpId
    },
    getCoordinatesByType (object) {
      if (this.isTmpWkt(object)) {
        return object.wkt
      } else if (this.isTempGeolocate(object)) {
        return object.iframe_response
      } else {
        return this.getCoordinates(this.geojsonObject(object).geometry.coordinates)
      }
    }
  }
}
</script>
