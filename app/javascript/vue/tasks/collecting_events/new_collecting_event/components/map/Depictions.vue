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
  </div>

</template>

<script>

import { GetDepictions, DestroyDepiction } from '../../request/resources.js'
import Dropzone from 'components/dropzone.vue'
import extendCE from '../mixins/extendCE.js'

export default {
  mixins: [extendCE],
  components: {
    Dropzone
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
      }
    }
  },
  watch: {
    collectingEvent (newVal, oldVal) {
      if (newVal.id && (newVal.id != oldVal.id)) {
        this.$refs.depiction.setOption('autoProcessQueue', true)
        this.$refs.depiction.processQueue()
        GetDepictions(newVal.id).then(response => {
          this.figuresList = response
        })
      } else {
        if(!newVal.id) {
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
    addedfile () {
      if (!this.collectingEvent.id) {
        this.$refs.depiction.setOption('autoProcessQueue', true)
        this.$refs.depiction.processQueue()
      }
    },
    removeDepiction (depiction) {
      if (window.confirm(`Are you sure want to proceed?`)) {
        DestroyDepiction(depiction.id).then(response => {
          TW.workbench.alert.create('Depiction was successfully deleted.', 'notice')
          this.figuresList.splice(this.figuresList.findIndex((figure) => { return figure.id == depiction.id }), 1)
          this.$emit('delete', depiction)
        })
      }
    },
    error (event) {
      TW.workbench.alert.create(`There was an error uploading the image: ${event.xhr.responseText}`, 'error')
    }
  }
}
</script>
