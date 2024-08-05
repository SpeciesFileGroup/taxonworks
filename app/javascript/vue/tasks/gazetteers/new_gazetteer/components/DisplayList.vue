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
          <td v-if="item.type == GZ_UNION">
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
  GZ_POINT,
  GZ_WKT,
  GZ_LEAFLET,
  GZ_UNION
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
  emit('delete', item)
}

function shapeType(item) {
  switch(item.type) {
    case GZ_LEAFLET:
      if (item.shape.properties.radius) {
        return 'Circle of radius ' + item.shape.properties.radius.toFixed(6) + 'm'
      }

      return item.shape.geometry.type
    case GZ_WKT:
      return 'WKT'
    case GZ_POINT:
      return 'Point'
    case GZ_UNION:
      return 'Geographic Area'
  }
}

function getCoordinates(item) {
  switch(item.type) {
    case GZ_LEAFLET:
      switch(shapeType(item)) {
        case 'GeometryCollection':
          return coordinatesForGeometryCollection(
              item.shape.geometry.geometries
            )

        default: // not GeometryCollection
          // TODO: this fails for Multi-shapes returned after Save (array shapes
          // are different)
          const coordinates = item.shape.geometry.coordinates
          const flattened = coordinates.flat(1)
          if (typeof flattened[0] === 'number') {
            return convertToLatLongOrder(coordinates)
          } else {
            return flattened.map((arr) => convertToLatLongOrder(arr))
          }
      }
      break

    case GZ_WKT:
      return item.shape

    case GZ_POINT:
      const coordinates =
        convertToLatLongOrder(item.shape.geometry.coordinates)
      return `Point (${coordinates[0]} ${coordinates[1]})`

    case GZ_UNION:
      return item.shape.label_html
  }
}

function coordinatesForGeometryCollection(geometries) {
  let collectionStrings = []
  geometries.forEach((geometry) => {
    let shape_hash
    if  (geometry.type == 'GeometryCollection') {
      // TODO test this (a geom_collection inside a geom_collection)
      shape_hash = {
        geometries: geometry.geometries
      }
    }
    else {
      shape_hash = {
        geometry
      }
    }
    shape_hash.properties = {}

    const new_shape = {
      type: GZ_LEAFLET,
      shape: shape_hash
    }

    // TODO how to display this type without double quotes?
    collectionStrings.push(geometry.type)
    collectionStrings.push(getCoordinates(new_shape))
  })

  return collectionStrings
}
</script>