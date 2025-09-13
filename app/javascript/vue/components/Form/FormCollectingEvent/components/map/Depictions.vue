<template>
  <div class="full_width">
    <fieldset>
      <legend>Depictions</legend>
      <SmartSelector
        model="images"
        default="new"
        :autocomplete="false"
        :search="false"
        :target="COLLECTING_EVENT"
        :add-tabs="['new']"
        pin-section="Images"
        :pin-type="IMAGE"
        @selected="addDepiction"
      >
        <template #new>
          <Dropzone
            class="dropzone-card"
            ref="depictionRef"
            url="/depictions"
            use-custom-dropzone-options
            :dropzone-options="DROPZONE_CONFIG"
            @vdropzone-sending="sending"
            @vdropzone-file-added="addedfile"
            @vdropzone-success="success"
            @vdropzone-error="error"
          />
        </template>
      </SmartSelector>
      <hr class="divisor margin-medium-top margin-medium-bottom" />
      <div
        class="flex-wrap-row"
        v-if="storeDepiction.depictions.length"
      >
        <DepictionImage
          v-for="item in storeDepiction.depictions"
          :key="item.id"
          :depiction="item"
          @delete="removeDepiction"
        />
      </div>
    </fieldset>
    <table
      v-if="store.exifGeoreferences.length"
      class="full_width"
    >
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
        <tr v-for="item in store.exifGeoreferences">
          <td>
            <input
              v-model="store.georeferences"
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
import { ref, computed, watch } from 'vue'
import {
  GEOREFERENCE_EXIF,
  COLLECTING_EVENT,
  IMAGE
} from '@/constants/index.js'
import EXIF from 'exifr'
import Dropzone from '@/components/dropzone.vue'
import ParseDMS from '@/helpers/parseDMS.js'
import addGeoreference from '../../helpers/addGeoreference.js'
import createGeoJSONFeature from '../../helpers/createGeoJSONFeature.js'
import DepictionImage from './depictionImage'
import useStore from '../../store/georeferences.js'
import useDepictionStore from '../../store/depictions.js'
import SmartSelector from '@/components/ui/SmartSelector.vue'

const DROPZONE_CONFIG = {
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

const store = useStore()
const storeDepiction = useDepictionStore()
const collectingEvent = defineModel({
  type: Object,
  required: true
})

const emit = defineEmits(['create', 'delete'])

const setAutogeo = computed({
  get() {
    return autogeo.value
  },
  set(value) {
    if (value) {
      store.exifGeoreferences.forEach((item) => {
        const found = store.georeferences.find((geo) => geo.uuid === item.uuid)
        if (!found) {
          store.georeferences.push(item)
        }
      })
    } else {
      store.exifGeoreferences.forEach((item) => {
        const index = store.georeferences.findIndex(
          (geo) => geo.uuid === item.uuid
        )
        if (index > -1) {
          store.georeferences.splice(index, 1)
        }
      })
    }
    autogeo.value = value
  }
})

const autogeo = ref(true)
const depictionRef = ref(null)

async function addDepiction(image) {
  if (!storeDepiction.getDepictionByImageId(image.id)) {
    storeDepiction.addImage(image)

    const response = await fetch(image.original_png)
    const blob = await response.blob()

    const objectUrl = URL.createObjectURL(blob)
    const img = new Image()
    img.src = objectUrl

    img.onload = () => {
      getEXIFFromFile(img).then((metadata) => {
        processEXIF(metadata)
      })
    }
  }
}

storeDepiction.$onAction(({ name, after }) => {
  after(() => {
    if (name === 'reset') {
      depictionRef.value?.removeAllFiles()
    }
  })
})

watch(
  () => collectingEvent.value.id,
  (newVal, oldVal) => {
    if (newVal && newVal !== oldVal) {
      depictionRef.value?.setOption('autoProcessQueue', true)
      depictionRef.value?.processQueue()
      store.exifGeoreferences = []
      storeDepiction.load({
        objectId: newVal,
        objectType: COLLECTING_EVENT
      })
    } else {
      if (!newVal) {
        storeDepiction.$reset()
        store.exifGeoreferences = []
        depictionRef.value?.setOption('autoProcessQueue', false)
      }
    }
  }
)

function success(file, response) {
  storeDepiction.depictions.push(response)
  depictionRef.value.removeFile(file)
  emit('create', response)
}

function sending(file, xhr, formData) {
  formData.append('depiction[depiction_object_id]', collectingEvent.value.id)
  formData.append('depiction[depiction_object_type]', 'CollectingEvent')
}

async function addedfile(file) {
  getEXIFFromFile(file).then((metadata) => {
    processEXIF(metadata)
  })

  if (collectingEvent.value.id) {
    depictionRef.value.setOption('autoProcessQueue', true)
    depictionRef.value.processQueue()
  }
}

function getEXIFFromFile(image) {
  return new Promise(async (resolve, reject) => {
    const metadata = await EXIF.parse(image)

    resolve(metadata)
  })
}

function isGeoreferenceAlreadyInList(geo) {
  const parsedGeo = parseGeoJson(geo)

  return store.exifGeoreferences.some((item) => {
    const parsedItem = parseGeoJson(item)

    return (
      parsedItem.latitude === parsedGeo.latitude &&
      parsedItem.longitude === parsedGeo.longitude
    )
  })
}

function processEXIF(allMetaData) {
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

    if (isGeoreferenceAlreadyInList(geojson)) return

    store.exifGeoreferences.push(geojson)
    if (autogeo.value) {
      store.georeferences.push(geojson)
    }

    setExifCoordinates(coordinates)
  }
  if (allMetaData?.DateTimeOriginal) {
    const d = allMetaData.DateTimeOriginal
    const pad = (n) => n.toString().padStart(2, '0')

    const date = [d.getFullYear(), pad(d.getMonth() + 1), pad(d.getDate())]
    const time = [pad(d.getHours()), pad(d.getMinutes()), pad(d.getSeconds())]

    setExitDate(date)
    setExifTime(time)
  }
}

function removeDepiction(depiction) {
  if (!depiction.id || window.confirm('Are you sure want to proceed?')) {
    storeDepiction.remove(depiction)
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
