<template>
  <div class="full_width">
    <dropzone
      class="dropzone-card"
      @vdropzone-sending="sending"
      @vdropzone-file-added="addedfile"
      @vdropzone-success="success"
      @vdropzone-error="error"
      ref="depiction"
      :id="`depiction-${dropzoneId}`"
      url="/depictions"
      :use-custom-dropzone-options="true"
      :dropzone-options="dropzone"/>
    <div
      class="flex-wrap-row"
      v-if="figuresList.length">
      <depictionImage
        v-for="item in figuresList"
        @delete="removeDepiction"
        :key="item.id"
        :depiction="item"/>
    </div>
    <table
      class="full_width">
      <thead>
        <tr>
          <th>
            <input
              v-model="setAutogeo"
              type="checkbox">
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
              type="checkbox">
          </td>
          <td>{{ parseGeoJson(item).latitude }}</td>
          <td>{{ parseGeoJson(item).longitude }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import { GetDepictions, DestroyDepiction } from '../../request/resources.js'
import GeoreferenceTypes from '../../const/georeferenceTypes'
import Dropzone from 'components/dropzone.vue'
import extendCE from '../mixins/extendCE.js'
import ParseDMS from 'helpers/parseDMS.js'
import addGeoreference from '../../helpers/addGeoreference.js'
import createGeoJSONFeature from '../../helpers/createGeoJSONFeature.js'
import DepictionImage from './depictionImage'
import EXIF from 'exif-js'

export default {
  mixins: [extendCE],
  components: {
    DepictionImage,
    Dropzone
  },
  computed: {
    queueGeoreferences: {
      get () {
        return this.$store.getters[GetterNames.GetQueueGeoreferences]
      },
      set (value) {
        this.$store.commit(MutationNames.SetQueueGeoreferences, value)
      }
    },
    setAutogeo: {
      get () {
        return this.autogeo
      },
      set (value) {
        if (value) {
          this.coordinatesEXIF.forEach(item => {
            const found = this.queueGeoreferences.find(geo => geo.tmpId === item.tmpId)
            if (!found) {
              this.queueGeoreferences.push(item)
            }
          })
        } else {
          this.coordinatesEXIF.forEach(item => {
            const index = this.queueGeoreferences.findIndex(geo => geo.tmpId === item.tmpId)
            if (index > -1) {
              this.queueGeoreferences.splice(index, 1)
            }
          })
        }
        this.autogeo = value
      }
    }
  },
  data () {
    return {
      figuresList: [],
      dropzoneId: Math.random().toString(36).substr(2, 5),
      autogeo: true,
      dropzone: {
        paramName: 'depiction[image_attributes][image_file]',
        url: '/depictions',
        autoProcessQueue: false,
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        dictDefaultMessage: 'Drop image or click to browse',
        acceptedFiles: 'image/*'
      },
      coordinatesEXIF: []
    }
  },
  watch: {
    collectingEvent (newVal, oldVal) {
      if (newVal.id && (newVal.id !== oldVal.id)) {
        this.$refs.depiction.setOption('autoProcessQueue', true)
        this.$refs.depiction.processQueue()
        this.coordinatesEXIF = []
        GetDepictions(newVal.id).then(response => {
          this.figuresList = response.body
        })
      } else {
        if (!newVal.id) {
          this.figuresList = []
          this.coordinatesEXIF = []
          this.$refs.depiction.setOption('autoProcessQueue', false)
        }
      }
    },
    queueGeoreferences: {
      handler (newVal, oldVal) {
        if (this.collectingEvent.id) {
          const removed = oldVal.filter(val => newVal.findIndex((v) => v.tmpId === val.tmpId) === -1)
          removed.forEach(item => {
            const index = this.coordinatesEXIF.findIndex(v => v.tmpId === item.tmpId)
            if (index > -1) {
              this.coordinatesEXIF.splice(index, 1)
            }
          })
        }
      },
      deep: true
    }
  },
  methods: {
    success (file, response) {
      this.figuresList.push(response)
      this.$refs.depiction.removeFile(file)
      this.$emit('create', response)
    },
    sending (file, xhr, formData) {
      formData.append('depiction[depiction_object_id]', this.collectingEvent.id)
      formData.append('depiction[depiction_object_type]', 'CollectingEvent')
    },
    addedfile (file) {
      EXIF.getData(file, () => {
        const allMetaData = EXIF.getAllTags(file)

        if (allMetaData?.GPSLatitude) {
          const coordinates = {
            latitude: ParseDMS(this.parseEXIFCoordinate(allMetaData.GPSLatitude) + allMetaData.GPSLatitudeRef),
            longitude: ParseDMS(this.parseEXIFCoordinate(allMetaData.GPSLongitude) + allMetaData.GPSLongitudeRef)
          }
          const geojson = addGeoreference(createGeoJSONFeature(coordinates.longitude, coordinates.latitude), GeoreferenceTypes.Exif)

          this.coordinatesEXIF.push(geojson)
          if (this.autogeo) {
            this.queueGeoreferences.push(geojson)
          }

          this.setExifCoordinates(coordinates)
        }
        if (allMetaData?.DateTimeOriginal) {
          let [date, time] = allMetaData.DateTimeOriginal.split(' ')

          date = date.split(':')
          time = time.split(':')
          this.setExitDate(date)
          this.setExifTime(time)
        }
      })
      if (this.collectingEvent.id) {
        this.$refs.depiction.setOption('autoProcessQueue', true)
        this.$refs.depiction.processQueue()
      }
    },
    removeDepiction (depiction) {
      if (window.confirm('Are you sure want to proceed?')) {
        DestroyDepiction(depiction.id).then(response => {
          TW.workbench.alert.create('Depiction was successfully deleted.', 'notice')
          this.figuresList.splice(this.figuresList.findIndex((figure) => { return figure.id == depiction.id }), 1)
          this.$emit('delete', depiction)
        })
      }
    },
    error (event) {
      TW.workbench.alert.create(`There was an error uploading the image: ${event.xhr.responseText}`, 'error')
    },
    parseEXIFCoordinate (GPSCoordinate) {
      return `${GPSCoordinate[0]}° ${GPSCoordinate[1]}' ${GPSCoordinate[2]}"`
    },
    parseGeoJson (georeference) {
      const coordinates = JSON.parse(georeference.geographic_item_attributes.shape).geometry.coordinates
      return { longitude: coordinates[0], latitude: coordinates[1] }
    },
    geoJsonLabel (coordinates) {
      return `Latitude: ${coordinates.latitude}, Longitude: ${coordinates.longitude}`
    },
    setExitDate (date) {
      if (!(this.collectingEvent.start_date_day || this.collectingEvent.start_date_month || this.collectingEvent.start_date_year)) {
        this.collectingEvent.start_date_day = date[2]
        this.collectingEvent.start_date_month = date[1]
        this.collectingEvent.start_date_year = date[0]
      }
    },
    setExifTime (time) {
      if (!(this.collectingEvent.time_start_hour || this.collectingEvent.time_start_minute || this.collectingEvent.time_start_second)) {
        this.collectingEvent.time_start_second = time[2]
        this.collectingEvent.time_start_minute = time[1]
        this.collectingEvent.time_start_hour = time[0]
      }
    },
    setExifCoordinates (coordinates) {
      if (!(this.collectingEvent.verbatim_latitude || this.collectingEvent.verbatim_latitude)) {
        this.collectingEvent.verbatim_latitude = coordinates.latitude
        this.collectingEvent.verbatim_longitude = coordinates.longitude
      }
    }
  }
}
</script>
