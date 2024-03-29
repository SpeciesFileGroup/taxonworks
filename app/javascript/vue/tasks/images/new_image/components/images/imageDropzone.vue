<template>
  <div class="image-container panel content">
    <dropzone
      class="dropzone-card"
      @vdropzone-success="success"
      ref="image"
      url="/images"
      use-custom-dropzone-options
      :dropzone-options="dropzone"
    />
    <div
      class="flex-wrap-row separate-top"
      v-if="figuresList.length"
    >
      <image-viewer
        v-for="item in figuresList"
        :key="item.id"
        :image="item"
        @delete="$emit('delete', $event)"
      />
      <div
        data-icon="reset"
        class="reset-button"
        @click="clearImages"
      >
        <span>Clear images</span>
      </div>
    </div>
  </div>
</template>

<script>
import { ActionNames } from '../../store/actions/actions.js'
import Dropzone from '@/components/dropzone.vue'
import ImageViewer from './imageViewer.vue'
import { GetterNames } from '../../store/getters/getters.js'

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

  emits: ['update:modelValue', 'created', 'onClear', 'delete'],

  data() {
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
          'X-CSRF-Token': document
            .querySelector('meta[name="csrf-token"]')
            .getAttribute('content')
        },
        dictDefaultMessage: 'Drop images here',
        acceptedFiles: 'image/*,.heic'
      }
    }
  },

  methods: {
    success(file, response) {
      const isCreated = this.figuresList.some((item) => item.id === response.id)

      this.$refs.image.removeFile(file)

      if (!isCreated) {
        this.figuresList.push(response)
        this.$emit('update:modelValue', this.figuresList)
        this.$emit('created', response)
        this.$store.dispatch(ActionNames.SetAllApplied, false)
      }
    },

    clearImages() {
      const message = this.$store.getters[GetterNames.IsAllApplied]
        ? 'Are you sure you want to clear the images?'
        : 'You have images without applying changes, are you sure you want to clean the images?'

      if (window.confirm(message)) {
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
