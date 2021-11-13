<template>
  <div class="depiction-container">
    <dropzone
      class="dropzone-card separate-bottom"
      @vdropzone-sending="sending"
      @vdropzone-file-added="addedfile"
      @vdropzone-success="success"
      ref="depiction"
      id="depiction"
      url="/depictions"
      use-custom-dropzone-options
      :dropzone-options="dropzone"
    />
    <div
      class="flex-wrap-row"
      v-if="figuresList.length"
    >
      <depictionImage
        v-for="item in figuresList"
        @delete="removeDepiction"
        :key="item.id"
        :depiction="item"
      />
    </div>
  </div>
</template>

<script>

import ActionNames from '../store/actions/actionNames'
import { GetterNames } from '../store/getters/getters'
import { CollectionObject, Depiction } from 'routes/endpoints'

import Dropzone from 'components/dropzone.vue'
import DepictionImage from 'components/depictions/depictionImage.vue'

export default {
  components: {
    DepictionImage,
    Dropzone
  },

  computed: {
    getTypeMaterial () {
      return this.$store.getters[GetterNames.GetTypeMaterial]
    },

    getImages () {
      return this.$store.getters[GetterNames.GetTypeMaterial].collection_object.images
    }
  },

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
      if (newVal.id) {
        if (newVal.id !== oldVal.id) {
          this.$refs.depiction.setOption('autoProcessQueue', true)
          CollectionObject.depictions(newVal.collection_object.id).then(response => {
            this.figuresList = response.body
          })
        }
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
    },

    sending (file, xhr, formData) {
      formData.append('depiction[depiction_object_id]', this.getTypeMaterial.collection_object.id)
      formData.append('depiction[depiction_object_type]', 'CollectionObject')
    },

    addedfile () {
      if (!this.getTypeMaterial.id && !this.creatingType) {
        this.creatingType = true
        this.$store.dispatch(ActionNames.CreateTypeMaterial).then(_ => {
          setTimeout(() => {
            this.$refs.depiction.setOption('autoProcessQueue', true)
            this.$refs.depiction.processQueue()
            this.creatingType = false
          }, 500)
        }, () => {
          this.creatingType = false
        })
      }
    },

    removeDepiction (depiction) {
      if (window.confirm('Are you sure want to proceed?')) {
        Depiction.destroy(depiction.id).then(() => {
          TW.workbench.alert.create('Depiction was successfully deleted.', 'notice')
          this.figuresList.splice(this.figuresList.findIndex((figure) => figure.id === depiction.id), 1)
        })
      }
    }
  }
}
</script>
<style scoped>
  .depiction-container {
    width: 500px;
    max-width: 500px;
  }
</style>
