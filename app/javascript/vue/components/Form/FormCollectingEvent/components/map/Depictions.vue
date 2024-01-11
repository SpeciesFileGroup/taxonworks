<template>
  <div class="full_width">
    <Dropzone
      class="dropzone-card"
      @vdropzone-sending="sending"
      @vdropzone-file-added="addedfile"
      @vdropzone-success="success"
      @vdropzone-error="error"
      ref="depictionRef"
      :id="`depiction-${dropzoneId}`"
      url="/depictions"
      :use-custom-dropzone-options="true"
      :dropzone-options="dropzone"
    />
    <div
      class="flex-wrap-row"
      v-if="figuresList.length"
    >
      <DepictionImage
        v-for="item in figuresList"
        @delete="removeDepiction"
        :key="item.id"
        :depiction="item"
      />
    </div>
    <table class="full_width">
      <thead>
        <tr>
          <th>
            <input
              v-model="setAutogeo"
              type="checkbox"
            />
          </th>
          <th>Latitude</th>
          <th>Longitude</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="item in coordinatesEXIF">
          <td>
            <input
              v-model="queueGeoreferences"
              :value="item"
              type="checkbox"
            />
          </td>
          <td>{{ parseGeoJson(item).latitude }}</td>
          <td>{{ parseGeoJson(item).longitude }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
import { CollectingEvent, Depiction } from '@/routes/endpoints'
import { GEOREFERENCE_EXIF } from '@/constants/index.js'
import { ref, computed, watch } from 'vue'
import Dropzone from '@/components/dropzone.vue'
import ParseDMS from '@/helpers/parseDMS.js'
import addGeoreference from '../../helpers/addGeoreference.js'
import createGeoJSONFeature from '../../helpers/createGeoJSONFeature.js'
import DepictionImage from './depictionImage'
import EXIF from 'exif-js'
import useStore from '../../store/collectingEvent'

const store = useStore()
const collectingEvent = defineModel()

const emit = defineEmits(['create', 'delete'])

const setAutogeo = computed({
  get() {
    return autogeo.value
  },
  set(value) {
    if (value) {
      coordinatesEXIF.value.forEach((item) => {
        const found = store.queueGeoreferences.find(
          (geo) => geo.tmpId === item.tmpId
        )
        if (!found) {
          store.queueGeoreferences.push(item)
        }
      })
    } else {
      coordinatesEXIF.value.forEach((item) => {
        const index = store.queueGeoreferences.findIndex(
          (geo) => geo.tmpId === item.tmpId
        )
        if (index > -1) {
          store.queueGeoreferences.splice(index, 1)
        }
      })
    }
    autogeo.value = value
  }
})

const autogeo = ref(true)
const depictionRef = ref(null)
const figuresList = ref([])
const dropzoneId = Math.random().toString(36).substr(2, 5)
const dropzone = {
  paramName: 'depiction[image_attributes][image_file]',
  url: '/depictions',
  autoProcessQueue: false,
  headers: {
    'X-CSRF-Token': document
      .querySelector('meta[name="csrf-token"]')
      .getAttribute('content')
  },
  dictDefaultMessage: 'Drop image or click to browse',
  acceptedFiles: 'image/*,.heic'
}
const coordinatesEXIF = ref([])

watch(collectingEvent, (newVal, oldVal) => {
  if (newVal.id && newVal.id !== oldVal.id) {
    depictionRef.value.setOption('autoProcessQueue', true)
    depictionRef.value.processQueue()
    coordinatesEXIF.value = []
    CollectingEvent.depictions(newVal.id)
      .then((response) => {
        figuresList.value = response.body
      })
      .catch(() => {})
  } else {
    if (!newVal.id) {
      figuresList.value = []
      coordinatesEXIF.value = []
      depictionRef.value.setOption('autoProcessQueue', false)
    }
  }
})

watch(
  store.queueGeoreferences,
  (newVal, oldVal) => {
    if (collectingEvent.value.id) {
      const removed = oldVal.filter(
        (val) => newVal.findIndex((v) => v.tmpId === val.tmpId) === -1
      )
      removed.forEach((item) => {
        const index = coordinatesEXIF.value.findIndex(
          (v) => v.tmpId === item.tmpId
        )
        if (index > -1) {
          coordinatesEXIF.value.splice(index, 1)
        }
      })
    }
  },
  { deep: true }
)

function success(file, response) {
  figuresList.value.push(response)
  depictionRef.value.removeFile(file)
  emit('create', response)
}

function sending(file, xhr, formData) {
  formData.append('depiction[depiction_object_id]', collectingEvent.value.id)
  formData.append('depiction[depiction_object_type]', 'CollectingEvent')
}

function addedfile(file) {
  EXIF.getData(file, () => {
    const allMetaData = EXIF.getAllTags(file)

    if (allMetaData?.GPSLatitude) {
      const coordinates = {
        latitude: ParseDMS(
          parseEXIFCoordinate(allMetaData.GPSLatitude) +
            allMetaData.GPSLatitudeRef
        ),
        longitude: ParseDMS(
          parseEXIFCoordinate(allMetaData.GPSLongitude) +
            allMetaData.GPSLongitudeRef
        )
      }
      const geojson = addGeoreference(
        createGeoJSONFeature(coordinates.longitude, coordinates.latitude),
        GEOREFERENCE_EXIF
      )

      coordinatesEXIF.value.push(geojson)
      if (autogeo.value) {
        store.queueGeoreferences.push(geojson)
      }

      setExifCoordinates(coordinates)
    }
    if (allMetaData?.DateTimeOriginal) {
      let [date, time] = allMetaData.DateTimeOriginal.split(' ')

      date = date.split(':')
      time = time.split(':')
      setExitDate(date)
      setExifTime(time)
    }
  })

  if (collectingEvent.value.id) {
    depictionRef.value.setOption('autoProcessQueue', true)
    depictionRef.value.processQueue()
  }
}

function removeDepiction(depiction) {
  if (window.confirm('Are you sure want to proceed?')) {
    Depiction.destroy(depiction.id).then((_) => {
      TW.workbench.alert.create('Depiction was successfully deleted.', 'notice')
      figuresList.value.splice(
        figuresList.value.findIndex((figure) => figure.id === depiction.id),
        1
      )
      emit('delete', depiction)
    })
  }
}
function error(event) {
  TW.workbench.alert.create(
    `There was an error uploading the image: ${event.xhr.responseText}`,
    'error'
  )
}

function parseEXIFCoordinate(GPSCoordinate) {
  return `${GPSCoordinate[0]}° ${GPSCoordinate[1]}' ${GPSCoordinate[2]}"`
}

function parseGeoJson(georeference) {
  const shape = JSON.parse(georeference.geographic_item_attributes.shape)
  const [latitude, longitude] = shape.geometry.coordinates

  return {
    longitude,
    latitude
  }
}

function setExitDate(date) {
  if (
    !(
      collectingEvent.value.start_date_day ||
      collectingEvent.value.start_date_month ||
      collectingEvent.value.start_date_year
    )
  ) {
    collectingEvent.value.start_date_day = date[2]
    collectingEvent.value.start_date_month = date[1]
    collectingEvent.value.start_date_year = date[0]
  }
}

function setExifTime(time) {
  if (
    !(
      collectingEvent.value.time_start_hour ||
      collectingEvent.value.time_start_minute ||
      collectingEvent.value.time_start_second
    )
  ) {
    collectingEvent.value.time_start_second = time[2]
    collectingEvent.value.time_start_minute = time[1]
    collectingEvent.value.time_start_hour = time[0]
  }
}

function setExifCoordinates(coordinates) {
  if (
    !(
      collectingEvent.value.verbatim_latitude ||
      collectingEvent.value.verbatim_latitude
    )
  ) {
    collectingEvent.value.verbatim_latitude = coordinates.latitude
    collectingEvent.value.verbatim_longitude = coordinates.longitude
  }
}
</script>
