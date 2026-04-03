<template>
  <div class="vue-table-container">
    <table class="vue-table table-striped">
      <thead>
        <tr>
          <th class="word-keep-all line-nowrap">Georeference ID</th>
          <th class="word-keep-all">Shape</th>
          <th class="word-keep-all">Coordinates</th>
          <th class="word-keep-all">Has error polygon</th>
          <th class="word-keep-all line-nowrap">Error radius</th>
          <th class="word-keep-all">Inferred error radius</th>
          <th class="word-keep-all">Type</th>
          <th class="word-keep-all">Date</th>
          <th />
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="item in list"
          :key="item.uuid"
          class="list-complete-item"
        >
          <td>{{ item.id }}</td>
          <td class="word-keep-all">
            <span v-if="isTmpWkt(item) || isTempGeolocate(item)">
              Available after save
            </span>
            <span v-else>
              {{ getGeoJsonType(item) }}
            </span>
          </td>
          <td>{{ getCoordinatesByType(item) }}</td>
          <td>{{ item.has_error_polygon ? 'Yes' : 'No' }}</td>
          <td class="line-nowrap">
            <EditInPlace
              v-model="item.error_radius"
              @end="emit('update', item)"
            />
          </td>
          <td>{{ item.inferred_error_radius }}</td>
          <td class="word-keep-all">{{ item.type }}</td>
          <td>
            <div class="horizontal-left-content">
              <VDate
                v-model:day="item.day_georeferenced"
                v-model:month="item.month_georeferenced"
                v-model:year="item.year_georeferenced"
                placeholder
                @change="emit('dateChanged', item)"
              />
            </div>
          </td>
          <td>
            <div class="vue-table-options gap-small">
              <RadialAnnotator
                v-if="item.global_id"
                :global-id="item.global_id"
              />
              <VBtn
                :color="item.id ? 'destroy' : 'primary'"
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
      </tbody>
    </table>
  </div>
</template>

<script setup>
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import EditInPlace from '@/components/editInPlace'
import VDate from '@/components/ui/Date/DateFields.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { convertToLatLongOrder } from '@/helpers/geojson'
import { GEOREFERENCE_GEOLOCATE, GEOREFERENCE_WKT } from '@/constants/index.js'

const props = defineProps({
  list: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['delete', 'update', 'dateChanged'])

function deleteItem(item) {
  if (item.id) {
    if (
      window.confirm(
        "You're trying to delete this record. Are you sure want to proceed?"
      )
    ) {
      emit('delete', item)
    }
  } else {
    emit('delete', item)
  }
}
function getCoordinates(coordinates) {
  if (!coordinates) {
    return 'Available after save'
  }

  const flatten = coordinates.flat(1)

  return typeof flatten[0] === 'number'
    ? convertToLatLongOrder(coordinates)
    : flatten.map((arr) => convertToLatLongOrder(arr))
}
function geojsonObject(object) {
  return object.geo_json
    ? object.geo_json
    : JSON.parse(object.geographic_item_attributes.shape)
}

function getGeoJsonType(object) {
  return geojsonObject(object).geometry.type
}

function serializeGeometry(geometry) {
  if (!geometry) {
    return 'Available after save'
  }

  if (geometry.type === 'GeometryCollection') {
    return JSON.stringify(
      geometry.geometries.map((item) => ({
        type: item.type,
        coordinates: item.coordinates
      }))
    )
  }

  return geometry.coordinates
}

function formatGeometryCoordinates(geometry) {
  if (!geometry) {
    return 'Available after save'
  }

  if (geometry.type === 'GeometryCollection') {
    return serializeGeometry(geometry)
  }

  return getCoordinates(geometry.coordinates)
}

function truncateText(value) {
  const text = Array.isArray(value) ? JSON.stringify(value) : String(value)

  return text.length > 100 ? `${text.slice(0, 100)}...` : text
}

function getCoordinatesByType(object) {
  let value

  if (isTmpWkt(object)) {
    value = object.wkt
  } else if (isTempGeolocate(object)) {
    value = object.iframe_response
  } else {
    value = formatGeometryCoordinates(geojsonObject(object).geometry)
  }

  return truncateText(value)
}

function isTmpWkt(object) {
  return object.type === GEOREFERENCE_WKT && !object.id
}

function isTempGeolocate(object) {
  return object.type === GEOREFERENCE_GEOLOCATE && !object.id
}

</script>
