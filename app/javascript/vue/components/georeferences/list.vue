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
          class="list-complete-item"
        >
          <td>{{ item.id }}</td>
          <td class="word-keep-all">{{ item.geo_json.geometry.type }}</td>
          <td>{{ getCoordinates(item.geo_json.geometry.coordinates) }}</td>
          <td class="line-nowrap">
            <edit-in-place
              v-model="item.error_radius"
              @end="emit('updateGeo', item)"/>
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
                @click="emit('dateChanged', item)"
              >
                Update
              </v-btn>
            </div>
          </td>
          <td>
            <div class="horizontal-right-content">
              <radial-annotator :global-id="item.global_id"/>
              <v-btn
                color="destroy"
                circle
                @click="deleteItem(item)"
              >
                <v-icon
                  name="trash"
                  x-small
                />
              </v-btn>
            </div>
          </td>
        </tr>
      </transition-group>
    </table>
  </div>
</template>

<script setup>

import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import EditInPlace from 'components/editInPlace'
import DateComponent from 'components/ui/Date/DateFields.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'

const props = defineProps({
  list: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits([
  'update',
  'dateChanged',
  'delete',
  'updateGeo'
])

const deleteItem = item => {
  if (window.confirm('You\'re trying to delete this record. Are you sure want to proceed?')) {
    emit('delete', item)
  }
}

const getCoordinates = coordinates =>
  coordinates.map(coordinate => Array.isArray(coordinate)
    ? coordinate.map(item => item.slice(0, 2))
    : coordinate
  )

</script>
