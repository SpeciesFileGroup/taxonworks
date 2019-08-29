<template>
  <canvas
    :width="width"
    :height="height"/>
</template>

<script>
export default {
  props: {
    image: {
      type: Object,
      default: undefined
    },
    width: {
      type: Number,
      default: 400
    },
    height: {
      type: Number,
      default: 400
    }
  },
  data () {
    return {
      canvas: undefined
    }
  },
  watch: {
    image: {
      handler (newVal) {
        this.createCanvas()
      },
      deep: true
    }
  },
  methods: {
    createCanvas () {
      this.canvas = this.$el
      const context = this.canvas.getContext('2d')

      context.clearRect(0, 0, this.width, this.height)

      const imageAspectRatio = this.image.imageWidth / this.image.imageHeight

      const SratioW = this.image.imageWidth / this.width
      const SratioH = this.image.imageHeight / this.height

      const sourceX = Math.round(this.image.x * SratioW)
      const sourceY = Math.round((this.image.y * SratioH * imageAspectRatio))
      const sourceWidth = Math.round(this.image.width * SratioW)
      const sourceHeight = Math.round(this.image.height * SratioH * imageAspectRatio)

      const ratioH = this.image.imageHeight / this.height
      const ratioW = this.image.imageWidth / this.width

      var destHeight
      var destWidth

      if (this.image.width >= this.image.height) {
        destWidth = this.image.imageWidth / ratioW
        destHeight = (this.image.height / this.image.width) * destWidth
      } else {
        destHeight = this.image.imageHeight / ratioH
        destWidth = (this.image.width / this.image.height) * destHeight
      }

      const destX = this.width / 2 - destWidth / 2
      const destY = 0
      const imageCanvas = new Image()

      imageCanvas.src = this.image.src

      imageCanvas.onload = () => {
        context.drawImage(imageCanvas, sourceX, sourceY, sourceWidth, sourceHeight, destX, destY, destWidth, destHeight)
      }
    }
  }
}
</script>