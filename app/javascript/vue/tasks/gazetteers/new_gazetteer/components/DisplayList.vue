<template>
  <div class="vue-table-container">
    <table class="vue-table">
      <thead>
        <tr>
          <th class="word-keep-all">Shape</th>
          <th class="word-keep-all">Coordinates</th>
          <th class="word-keep-all">Type</th>
          <th />
        </tr>
      </thead>
      <TransitionGroup
        name="list-complete"
        tag="tbody"
      >
        <tr
          v-for="item in list"
          :key="item.uuid"
          class="list-complete-item"
        >
          <td class="word-keep-all">{{ shapeType(item) }}</td>
          <td>{{ getCoordinates(item) }}</td>
          <td>{{ item.type }}</td>
          <td>
            <div class="horizontal-right-content gap-small">
              <RadialAnnotator
                v-if="item.global_id"
                :global-id="item.global_id"
              />
              <VBtn
                v-if="!editingDisabled"
                color="primary"
                circle
                @click="deleteItem(item)"
              >
                <VIcon
                  name="trash"
                  x-small
                />
              </VBtn>
            </div>
          </td>
        </tr>
      </TransitionGroup>
    </table>
  </div>
</template>

<script setup>
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { convertToLatLongOrder } from '@/helpers/geojson.js'
import {
  //GZ_POINT,
  GZ_WKT,
  GZ_LEAFLET
} from '@/constants/index.js'

const props = defineProps({
  list: {
    type: Array,
    default: () => []
  },
  editingDisabled: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['delete'])

function deleteItem(item) {
  if (
    window.confirm(
      "You're trying to delete this record. Are you sure want to proceed?"
    )
  ) {
    emit('delete', item)
  }
}

function shapeType(item) {
  switch(item.type) {
    case GZ_LEAFLET:
      return item.shape.geometry.type
    case GZ_WKT:
      return 'WKT'
  }
}

function getCoordinates(item) {
  switch(item.type) {
    case GZ_LEAFLET:
      const coordinates = item.shape.geometry.coordinates
      const flattened = coordinates.flat(1)
      if (typeof flattened[0] === 'number') {
        return convertToLatLongOrder(coordinates)
      } else {
        return flattened.map((arr) => convertToLatLongOrder(arr))
      }
      break
    case GZ_WKT:
      return item.shape
  }
}
</script>