<template>
  <div class="depiction-container">
    <spinner
      v-if="false"
      :show-spinner="false"
      legend="Create a type specimen to upload images"/>
    <dropzone
      class="dropzone-card separate-bottom"
      @vdropzone-sending="sending"
      @vdropzone-file-added="addedfile"
      @vdropzone-success="success"
      ref="depiction"
      id="depiction"
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

import { Depiction } from 'routes/endpoints'
import Dropzone from 'components/dropzone.vue'
import Spinner from 'components/spinner.vue'
import DepictionImage from './depictionImage.vue'

export default {
  components: {
    DepictionImage,
    Dropzone,
    Spinner
  },

  props: {
    objectId: {
      type: [String, Number],
      required: true
    },
    objectType: {
      type: String,
      required: true
    }
  },

  emits: ['created'],

  data () {
    return {
      creatingType: false,
      displayBody: true,
      figuresList: [],
      dropzone: {
        paramName: 'depiction[image_attributes][image_file]',
        url: '/depictions',
        autoProcessQueue: false,
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        dictDefaultMessage: 'Drop images here to add figures',
        acceptedFiles: 'image/*,.heic'
      }
    }
  },
  watch: {
    getTypeMaterial (newVal, oldVal) {
      if (newVal.id && (newVal.id != oldVal.id)) {
        this.$refs.depiction.setOption('autoProcessQueue', true)
        Depiction.find(newVal.collection_object.id).then(response => {
          this.figuresList = response
        })
      } else {
        this.figuresList = []
        this.$refs.depiction.setOption('autoProcessQueue', false)
      }
    }
  },
  methods: {
    success (file, response) {
      this.figuresList.push(response)
      this.$refs.depiction.removeFile(file)
      this.$emit('created', response)
    },

    sending (file, xhr, formData) {
      formData.append('depiction[depiction_object_id]', this.objectId)
      formData.append('depiction[depiction_object_type]', this.objectType)
    },

    addedfile () {
      if (!this.getTypeMaterial.id && !this.creatingType) {
        this.creatingType = true
      }
    },

    removeDepiction (depiction) {
      if (window.confirm('Are you sure want to proceed?')) {
        Depiction.destroy(depiction.id).then(_ => {
          TW.workbench.alert.create('Depiction was successfully deleted.', 'notice')
          this.figuresList.splice(this.figuresList.findIndex(figure => figure.id === depiction.id), 1)
        })
      }
    }
  }
}
</script>
