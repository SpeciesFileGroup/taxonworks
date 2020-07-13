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
    <div v-if="coordinatesEXIF.length">
      <h3>Create georeferences from image EXIF</h3>
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
import ParseDMS from 'helpers/parseDMS'
import EXIF from 'exif-js'

export default {
  mixins: [extendCE],
  components: {
    Dropzone
  },
  computed: {
    coordinatesEXIF () {
      return this.imagesEXIF.filter(item => item.hasOwnProperty('GPSLatitude')).map((item) => {
        return {
          latitude: ParseDMS(this.parseEXIFCoordinate(item.GPSLatitude) + item.GPSLatitudeRef),
          longitude: ParseDMS(this.parseEXIFCoordinate(item.GPSLongitude) + item.GPSLongitudeRef)
        }
      })
    }
  },
  data () {
    return {
      figuresList: [],
      dropzoneId: Math.random().toString(36).substr(2, 5),
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
      imagesEXIF: [],
      coordinatesQueue: []
    }
  },
  watch: {
    collectingEvent (newVal, oldVal) {
      if (newVal.id && (newVal.id !== oldVal.id)) {
        this.$refs.depiction.setOption('autoProcessQueue', true)
        this.$refs.depiction.processQueue()
        this.processGeoreferencesQueue()
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
        this.imagesEXIF.push(allMetaData)
        console.log(JSON.stringify(allMetaData, null, '\t'))
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
    processGeoreferencesQueue () {
      this.coordinatesQueue.forEach(geo => {
        const shape = {
          type: 'Feature',
          properties: {},
          geometry: {
            type: 'Point',
            coordinates: [geo.longitude, geo.latitude]
          }
        }
        const data = {
          georeference: {
            geographic_item_attributes: { shape: JSON.stringify(shape) },
            collecting_event_id: this.collectingEventId,
            type: 'Georeference::Exif'
          }
        }
        CreateGeoreference(data).then(response => {
          console.log(response)
        })
      })
    }
  }
}
</script>
