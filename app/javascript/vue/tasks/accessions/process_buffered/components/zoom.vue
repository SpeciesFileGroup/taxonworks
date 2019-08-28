<template>
  <div class="flexbox">
    <depictions-container
      @selectedImage="image=$event"/>
    <div>
      <div class="horizontal-left-content align-start">
        <image-editor
          class="separate-right"
          :image="image"
          @imagePosition="setImageValues"/>
        <canvas-container :image="canvasImage"/>
      </div>
    </div>
  </div>
</template>

<script>

import DepictionsContainer from './depictionsContainer'
import ImageEditor from './imageEditor'
import CanvasContainer from './canvasContainer'

export default {
  components: {
    DepictionsContainer,
    ImageEditor,
    CanvasContainer
  },
  data () {
    return {
      image: undefined,
      canvasImage: undefined
    }
  },
  methods: {
    setImageValues (values) {
      this.canvasImage = {
        src: this.image.large_image,
        x: values.x,
        y: values.y,
        width: values.width,
        height: values.height,
        imageWidth: values.imageWidth,
        imageHeight: values.imageHeight
      }
    }
  }
}
</script>
