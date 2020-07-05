<template>
  <div class="vue-table-container">
    <table class="vue-table">
      <thead>
        <tr>
          <th>Georeference ID</th>
          <th>Shape</th>
          <th>Coordinates</th>
          <th>Error radius</th>
          <th>Type</th>
          <th></th>
        </tr>
      </thead>
      <transition-group
        name="list-complete"
        tag="tbody">
        <tr
          v-for="item in list"
          :key="item.id"
          class="list-complete-item">
          <td>{{ item.id }}</td>
          <td>{{ item.geo_json.geometry.type }}</td>
          <td>{{ getCoordinates(item.geo_json.geometry.coordinates) }}</td>
          <td>
            <edit-in-place 
              v-model="item.error_radius"
              @end="$emit('updateGeo', item)"/>
          </td>
          <td>{{ item.type }}</td>
          <td class="vue-table-options">
            <radial-annotator
              :global-id="item.global_id"/>
            <span
              v-if="destroy"
              class="circle-button btn-delete"
              @click="deleteItem(item)">Remove
            </span>
          </td>
        </tr>
      </transition-group>
    </table>
  </div>
</template>
<script>

import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import EditInPlace from 'components/editInPlace'

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
    }
  }
}
</script>
