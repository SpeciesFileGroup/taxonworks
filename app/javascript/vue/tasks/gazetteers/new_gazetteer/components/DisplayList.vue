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
          <td v-if="item.type == GZ_COMBINE_GA || item.type == GZ_COMBINE_GZ">
            <span v-html="getCoordinates(item)" />
          </td>
          <td v-else>{{ getCoordinates(item) }}</td>
          <td>{{ item.type }}</td>
          <td>
            <div class="horizontal-right-content gap-small">
              <RadialAnnotator
                v-if="item.global_id"
                :global-id="item.global_id"
              />
              <VBtn
                color="primary"
                icon
                variant="tonal"
                @click="() => deleteItem(item)"
              >
                <IconTrash class="w-4 h-4" />
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
import IconTrash from '@/components/Icon/IconTrash.vue'
import {
  convertToLatLongOrder,
  formatGeoJsonGeometryForDisplay
} from '@/helpers/geojson.js'
import {
  GZ_POINT,
  GZ_WKT,
  GZ_LEAFLET,
  GZ_COMBINE_GA,
  GZ_COMBINE_GZ,
  GZ_DATABASE
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

function shapeType(item) {
  switch(item.type) {
    case GZ_LEAFLET:
    case GZ_DATABASE:
      if (item.shape.properties.radius) {
        return `Circle of radius ${item.shape.properties.radius.toFixed(6)}m`
      }

      return item.shape.geometry.type
    case GZ_WKT:
      return 'WKT'
    case GZ_POINT:
      return 'Point'
    case GZ_COMBINE_GA:
      return 'Geographic Area'
    case GZ_COMBINE_GZ:
      return 'Gazetteer'
  }
}

function getCoordinates(item) {
  switch(item.type) {
    case GZ_LEAFLET:
    case GZ_DATABASE:
      return coordinatesForListItem(item)

    case GZ_WKT:
      return item.shape

    case GZ_POINT:
      const coordinates =
        convertToLatLongOrder(item.shape.geometry.coordinates)
      return `Point (${coordinates[0]} ${coordinates[1]})`

    case GZ_COMBINE_GA:
    case GZ_COMBINE_GZ:
      return item.shape.label_html
  }
}

// TODO? Return this as valid WKT
function coordinatesForListItem(item) {
  return formatGeoJsonGeometryForDisplay(item.shape.geometry, 150)
}

function deleteItem(item) {
  if (item.type == GZ_DATABASE) {
    if (
      window.confirm(
        `You're trying to delete the *SAVED* shape. This can't be undone. Are you sure?`
      )
    ) {
      emit('delete', item)
    }
  } else {
    emit('delete', item)
  }
}
</script>
