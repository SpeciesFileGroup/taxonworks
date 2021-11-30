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
          <th class="word-keep-all">Date</th>
          <th />
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
          <td class="word-keep-all">{{ item.geo_json.geometry.type }}</td>
          <td>{{ getCoordinates(item.geo_json.geometry.coordinates) }}</td>
          <td class="line-nowrap">
            <edit-in-place
              v-model="item.error_radius"
              @end="$emit('updateGeo', item)"/>
          </td>
          <td class="word-keep-all">{{ item.type }}</td>
          <td>
            <div class="horizontal-left-content">
              <date-component
                class="margin-small-right"
                v-model:day="item.day_georeferenced"
                v-model:month="item.month_georeferenced"
                v-model:year="item.year_georeferenced"
                placeholder
              />
              <v-btn
                color="update"
                medium
                @click="$emit('dateChanged', item)"
              >
                Update
              </v-btn>
            </div>
          </td>
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
import DateComponent from 'components/ui/Date/DateFields.vue'
import VBtn from 'components/ui/VBtn/index.vue'

export default {
  components: {
    RadialAnnotator,
    EditInPlace,
    DateComponent,
    VBtn
  },

  props: {
    list: {
      type: Array,
      default: () => []
    },
    header: {
      type: Array,
      default: () => []
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

  emits: [
    'update',
    'dateChanged',
    'delete',
    'updateGeo'
  ],

  methods: {
    deleteItem (item) {
      if (this.deleteWarning) {
        if (window.confirm('You\'re trying to delete this record. Are you sure want to proceed?')) {
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
