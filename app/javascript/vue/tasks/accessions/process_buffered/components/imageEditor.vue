<template>
  <svg
    :width="width/scale"
    :height="height/scale"
    :viewBox="`0 0 ${width/scale} ${height/scale}`"
    @mousemove="onMouseMove"
    @mouseup="dragEnd">
    <image
      :xlink:href="image.large_image"
      :width="width/scale"
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
      @mousemove="onMouseMove"/>
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
      return this.image ? Number(this.image.large_height_width.split(', ')[0]) : 0
    },
    height () {
      return this.image ? Number(this.image.large_height_width.split(', ')[1]) : 0
    },
    scale () {
      const scaleHeight = this.height > this.maxHeight ? this.height / this.maxHeight : 1
      const scaleWidth = this.width > this.maxWidth ? this.width / this.maxWidth : 1

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
      canvas: undefined,
      currentMouseX: 0,
      currentMouseY: 0,
      lastMouseX: 0,
      lastMouseY: 0
    }
  },
  methods: {
    resetStates () {
      this.dragging = false
      this.resize = false
      this.cursorStyle = undefined
    },
    checkDrag (e, deltaX, deltaY) {
      console.log([deltaX, deltaY])
      console.log([deltaX - this.lastMouseX, deltaY - this.lastMouseY])
      if (!this.dragging) return

      switch (this.cursorStyle) {
        case 'move':
          this.svgBoxStyle.x = this.svgBoxStyle.x + deltaX - this.lastMouseX
          this.svgBoxStyle.y = this.svgBoxStyle.y + deltaY - this.lastMouseY
          break
        case 'se-resize':
          this.svgBoxStyle.width = e.offsetX - this.svgBoxStyle.x
          this.svgBoxStyle.height = e.offsetY - this.svgBoxStyle.y
          break
        case 'sw-resize':
          this.svgBoxStyle.x =  this.svgBoxStyle.x + (deltaX - this.lastMouseX)
          this.svgBoxStyle.width = this.svgBoxStyle.width - (deltaX - this.lastMouseX)
          this.svgBoxStyle.height = this.svgBoxStyle.height + (deltaY - this.lastMouseY)
          break
        case 'nw-resize':
          this.svgBoxStyle.x =  this.svgBoxStyle.x + (deltaX - this.lastMouseX)
          this.svgBoxStyle.y = this.svgBoxStyle.y + (deltaY - this.lastMouseY)
          this.svgBoxStyle.width = this.svgBoxStyle.width - (deltaX - this.lastMouseX)
          this.svgBoxStyle.height = this.svgBoxStyle.height - (deltaY - this.lastMouseY)
          break
        case 'ne-resize':
          //this.svgBoxStyle.x =  this.svgBoxStyle.x  (deltaX - this.lastMouseX)
          this.svgBoxStyle.y = this.svgBoxStyle.y + (deltaY - this.lastMouseY)
          this.svgBoxStyle.width = this.svgBoxStyle.width + (deltaX - this.lastMouseX)
          this.svgBoxStyle.height = this.svgBoxStyle.height - (deltaY - this.lastMouseY)
          break
        case 'w-resize':
          this.svgBoxStyle.x =  this.svgBoxStyle.x + (deltaX - this.lastMouseX)
          this.svgBoxStyle.width = this.svgBoxStyle.width - (deltaX - this.lastMouseX)
          break
        case 'e-resize':
          this.svgBoxStyle.width = this.svgBoxStyle.width + (deltaX - this.lastMouseX)
          break
        case 'n-resize':
          this.svgBoxStyle.y = this.svgBoxStyle.y + (deltaY - this.lastMouseY)
          this.svgBoxStyle.height = this.svgBoxStyle.height - (deltaY - this.lastMouseY)
          break
        case 's-resize':
          this.svgBoxStyle.height = this.svgBoxStyle.height + (deltaY - this.lastMouseY)
          break
        default:
          break
      }
      this.lastMouseX = e.pageX
      this.lastMouseY = e.pageY
    },
    dragEnd () {
      if (this.dragging) {
        this.$emit('imagePosition', {
          x: this.svgBoxStyle.x * this.scale,
          y: this.svgBoxStyle.y * this.scale,
          width: this.svgBoxStyle.width * this.scale,
          height: this.svgBoxStyle.height * this.scale,
          imageWidth: this.width,
          imageHeight: this.height,
          scale: this.scale
        })
      }
      this.resetStates()
    },
    changeCursor (event) {
      if (this.dragging || this.dragging) return
      this.movedElement = event.srcElement

      const relativeX = event.clientX - (this.$el.getBoundingClientRect().left + document.body.scrollLeft) - this.svgBoxStyle.x
      const relativeY = event.clientY - (this.$el.getBoundingClientRect().top + document.body.scrollTop) - this.svgBoxStyle.y
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
    },
    onMouseMove (event) {
      this.currentMouseX = event.clientX - (this.$el.getBoundingClientRect().left + document.body.scrollLeft)
      this.currentMouseY = event.clientY - (this.$el.getBoundingClientRect().top + document.body.scrollTop)

      this.changeCursor(event)
      this.checkDrag(event, this.currentMouseX, this.currentMouseY)

      this.lastMouseX = this.currentMouseX
      this.lastMouseY = this.currentMouseY
    }
  }
}
</script>
