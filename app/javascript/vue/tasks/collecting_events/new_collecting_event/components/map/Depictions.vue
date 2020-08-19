<template>
  <div class="full_width">
    <dropzone
      class="dropzone-card separate-bottom"
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
    <div>
      <label>
        <input
          v-model="autogeo"
          type="checkbox"> Create georeferences from EXIF
      </label>
    </div>
    <div v-if="coordinatesEXIF.length">
      <ul class="no_bullets">
        <li v-for="item in coordinatesEXIF">
          <label class="middle">
            <input
              v-model="coordinatesQueue"
              :value="item"
              type="checkbox">
            {{ item }}
          </label>
        </li>
      </ul>
      <button
        type="button"
        class="button normal-input button-submit margin-medium-top">
        Create
      </button>
    </div>
  </div>
</template>

<script>

import { CreateGeoreference, GetDepictions, DestroyDepiction } from '../../request/resources.js'
import Dropzone from 'components/dropzone.vue'
import extendCE from '../mixins/extendCE.js'
import ParseDMS from 'helpers/parseDMS.js'
import addGeoreference from '../../helpers/addGeoreference.js'
import createGeoJSONFeature from '../../helpers/createGeoJSONFeature.js'
import EXIF from 'exif-js'

export default {
  mixins: [extendCE],
  components: {
    Dropzone
  },
  computed: {
    queueGeoreferences: {
      get () {
        return this.collectingEvent.queueGeoreferences
      },
      set (value) {
        this.collectingEvent.queueGeoreferences = value
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
        dictDefaultMessage: 'Drop images or click here to add figures',
        acceptedFiles: 'image/*'
      },
      coordinatesEXIF: [],
      coordinatesQueue: []
    }
  },
  watch: {
    collectingEvent (newVal, oldVal) {
      if (newVal.id && (newVal.id !== oldVal.id)) {
        this.$refs.depiction.setOption('autoProcessQueue', true)
        this.$refs.depiction.processQueue()
        GetDepictions(newVal.id).then(response => {
          this.figuresList = response
        })
      } else {
        if (!newVal.id) {
          this.figuresList = []
          this.$refs.depiction.setOption('autoProcessQueue', false)
        }
      }
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
        var allMetaData = EXIF.getAllTags(file)
        if (allMetaData.hasOwnProperty('GPSLatitude')) {
          const coordinates = {
            latitude: ParseDMS(this.parseEXIFCoordinate(allMetaData.GPSLatitude) + allMetaData.GPSLatitudeRef),
            longitude: ParseDMS(this.parseEXIFCoordinate(allMetaData.GPSLongitude) + allMetaData.GPSLongitudeRef)
          }
          this.coordinatesEXIF.push(coordinates)
          if (this.autogeo) {
            this.collectingEvent.queueGeoreferences.push(addGeoreference(createGeoJSONFeature(coordinates.longitude, coordinates.latitude, 'Georeference::Exit')))
          }
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
    }
  }
}
</script>
