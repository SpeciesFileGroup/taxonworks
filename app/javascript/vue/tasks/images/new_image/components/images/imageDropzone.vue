<template>
  <div class="image-container">
    <dropzone
      class="dropzone-card separate-bottom"
      @vdropzone-success="success"
      ref="image"
      url="/images"
      :use-custom-dropzone-options="true"
      :dropzone-options="dropzone"/>
    <div
      class="flex-wrap-row"
      v-if="figuresList.length">
      <image-viewer
        v-for="item in figuresList"
        :key="item.id"
        :image="item"
        @delete="$emit('delete', $event)"/>
      <div
        data-icon="reset"
        class="reset-button"
        @click="clearImages">
        <span>Clear images</span>
      </div>
    </div>
  </div>
</template>

<script>

import Dropzone from 'components/dropzone.vue'
import ImageViewer from './imageViewer.vue'

export default {
  components: {
    ImageViewer,
    Dropzone
  },

  props: {
    modelValue: {
      type: Array,
      default: () => []
    }
  },

  watch: {
    modelValue: {
      handler(newVal) {
        this.figuresList = newVal
      },
      deep: true
    }
  },

  emits: [
    'update:modelValue',
    'created',
    'onClear',
    'delete'
  ],

  data () {
    return {
      creatingType: false,
      displayBody: true,
      figuresList: [],
      dropzone: {
        paramName: 'image[image_file]',
        url: '/images',
        autoProcessQueue: true,
        parallelUploads: 1,
        timeout: 600000,
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        dictDefaultMessage: 'Drop images here',
        acceptedFiles: 'image/*,.heic'
      }
    }
  },

  methods: {
    success (file, response) {
      this.figuresList.push(response)
      this.$refs.image.removeFile(file)
      this.$emit('update:modelValue', this.figuresList)
      this.$emit('created', response)
    },

    clearImages () {
      if (window.confirm('Are you sure you want to clear the images?')) {
        this.$emit('update:modelValue', [])
        this.$emit('onClear')
      }
    }
  }
}
</script>

<style scoped>
  .reset-button {
    margin: 4px;
    width: 100px;
    height: 65px;
    padding: 0px;
    padding-top: 10px;
    background-position: center;
    background-position-y: 30px;
    background-size: 30px;
    text-align: center;
  }
  .reset-button:hover {
    opacity: 0.8;
    cursor: pointer;
  }
</style>
