<template>
  <div class="flexbox">
    <depictions-container
      :depictions="depictions"
      @selectedImage="image=$event"/>
    <div>
      <div class="horizontal-left-content">
        <image-editor
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
      image: undefined
    }
  },
  methods: {
    setImageValues (values) {
      this.canvasImage = {
        src: this.image.large_image,
        x: values.x,
        y: values.y,
        width: values.width,
        height: values.height
      }
    }
  }
}
</script>
