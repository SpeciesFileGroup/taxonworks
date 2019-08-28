<template>
  <svg
    :width="width*scale"
    :height="height*scale"
    @mousemove="checkDrag"
    @mouseup="dragEnd">
    <image
      :xlink:href="image.large_image"
      :height="height*scale"
      :width="width*scale"
      :x="0"
      :y="0"/>
    <rect
      :x="svgBoxStyle.x"
      :y="svgBoxStyle.y"
      :width="svgBoxStyle.width"
      :height="svgBoxStyle.height"
      :fill="svgBoxStyle.fill"
      :stroke="svgBoxStyle.stroke"
      :opacity="svgBoxStyle.opacity"
      :stroke-width="svgBoxStyle['stroke-width']"
      @mousedown="dragging = true"
      @mouseup="dragEnd"
      @mousemove="changeCursor"/>
  </svg>
</template>
<script>
export default {
  props: {
    image: {
      type: [String, Object],
      default: undefined
    },
    maxWidth: {
      type: Number,
      default: 300
    },
    maxHeight: {
      type: Number,
      default: 300
    }
  },
  computed: {
    width () {
      return this.image ? this.image.large_height_width.split(', ')[0] : 0
    },
    height () {
      return this.image ? this.image.large_height_width.split(', ')[1] : 0
    },
    scale () {
      const scaleHeight = this.height > this.maxHeight ? this.height / this.imageHeight : 1
      const scaleWidth = this.width > this.maxWidth ? this.width / window.outerWidth : 1

      return scaleHeight > scaleWidth ? scaleHeight : scaleWidth
    }
  },
  data () {
    return {
      movedElement: undefined,
      svgBoxStyle: {
        x: 0,
        y: 0,
        width: 50,
        height: 50,
        fill: '#ffffff',
        stroke: '#000000',
        'stroke-width': 1,
        opacity: 0.4
      },
      cursorStyle: undefined,
      dragging: false,
      resize: false,
      canvas: undefined
    }
  },
  methods: {
    resetStates () {
      this.dragging = false
      this.resize = false
      this.cursorStyle = undefined
    },
    checkDrag (e) {
      if (!this.dragging) return
      if (this.cursorStyle === 'move') {
        this.svgBoxStyle.x = e.offsetX
        this.svgBoxStyle.y = e.offsetY
      } else {
        this.svgBoxStyle.width = e.offsetX - this.svgBoxStyle.x
        this.svgBoxStyle.height = e.offsetY - this.svgBoxStyle.y
      }
    },
    dragEnd () {
      if (this.dragging) {
        this.$emit('imagePosition', {
          x: this.svgBoxStyle.x / this.scale,
          y: this.svgBoxStyle.y / this.scale,
          width: this.svgBoxStyle.width / this.scale,
          height: this.svgBoxStyle.height / this.scale,
          imageWidth: this.width,
          imageHeight: this.height,
          scale: this.scale
        })
      }
      this.resetStates()
    },
    changeCursor (e) {
      if (this.dragging || this.dragging) return
      this.movedElement = e.srcElement

      const relativeX = e.clientX - (this.$el.getBoundingClientRect().left + document.body.scrollLeft) - this.svgBoxStyle.x
      const relativeY = e.clientY - (this.$el.getBoundingClientRect().top + document.body.scrollTop) - this.svgBoxStyle.y
      const shapeWidth = this.svgBoxStyle.width
      const shapeHeight = this.svgBoxStyle.height
      const resizeBorder = 10

      if (relativeX < resizeBorder && relativeY < resizeBorder) {
        this.cursorStyle = 'nw-resize'
      } else if (relativeX > shapeWidth - resizeBorder && relativeY < resizeBorder) {
        this.cursorStyle = 'ne-resize'
      } else if (relativeX > shapeWidth - resizeBorder && relativeY > shapeHeight - resizeBorder) {
        this.cursorStyle = 'se-resize'
      } else if (relativeX < resizeBorder && relativeY > shapeHeight - resizeBorder) {
        this.cursorStyle = 'sw-resize'
      } else if (relativeX < resizeBorder && relativeY < shapeHeight - resizeBorder) {
        this.cursorStyle = 'w-resize'
      } else if (relativeX > shapeWidth - resizeBorder && relativeY < shapeHeight - resizeBorder) {
        this.cursorStyle = 'e-resize'
      } else if (relativeX > resizeBorder && relativeY > shapeHeight - resizeBorder) {
        this.cursorStyle = 's-resize'
      } else if (relativeX > resizeBorder && relativeY < resizeBorder) {
        this.cursorStyle = 'n-resize'
      } else {
        this.cursorStyle = 'move'
      }
      this.movedElement.setAttribute('cursor', this.cursorStyle)
    }
  }
}
</script>
