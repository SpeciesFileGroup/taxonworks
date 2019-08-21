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
    }
  },
  data () {
    return {
      canvas: undefined,
      width: 400,
      height: 400
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
      let context = this.canvas.getContext('2d')

      context.clearRect(0, 0, this.width, this.height)
      let imageCanvas = new Image()
      imageCanvas.src = this.image.src
      context.drawImage(imageCanvas, this.image.x, this.image.y, this.image.width, this.image.height, 0, 0, 400, 400)
    }
  }
}
</script>

<style>

</style>