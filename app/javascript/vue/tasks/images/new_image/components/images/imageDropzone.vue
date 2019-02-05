<template>
  <div class="image-container">
    <dropzone
      class="dropzone-card separate-bottom"
      @vdropzone-success="success"
      ref="image"
      id="image"
      url="/images"
      :use-custom-dropzone-options="true"
      :dropzone-options="dropzone"/>
    <div
      class="flex-wrap-row"
      v-if="figuresList.length">
      <image-viewer
        v-for="item in figuresList"
        :key="item.id"
        :image="item"/>
    </div>
  </div>
</template>

<script>

import Dropzone from 'components/dropzone.vue'
import ImageViewer from './imageViewer.vue'

export default {
  components: {
    ImageViewer,
    Dropzone,
  },
  props: {
    value: {
      type: Array,
      default: () => { return [] }
    }
  },
  watch: {
    value: {
      handler(newVal) {
        this.figuresList = newVal
      }, 
      deep: true
    }
  },
  data: function () {
    return {
      creatingType: false,
      displayBody: true,
      figuresList: [],
      dropzone: {
        paramName: 'image[image_file]',
        url: '/images',
        autoProcessQueue: true,
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        dictDefaultMessage: 'Drop images here to add figures',
        acceptedFiles: 'image/*'
      }
    }
  },
  methods: {
    'success': function (file, response) {
      this.figuresList.push(response)
      this.$refs.image.removeFile(file)
      this.$emit('input', this.figuresList)
      this.$emit('created',response)
    },
  }
}
</script>
