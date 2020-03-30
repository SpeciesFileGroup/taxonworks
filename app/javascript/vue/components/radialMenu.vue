/*

menu structure:
[
	{
		label: 'Citation',
		total: 11,
		event: 'citation',
    size: 21, // This will set the size of the slice, if the value is undefined or didnt exist, the size will be set automatically depending the other slice size
		icon: {
			url: 'image.svg',
			width: '20',
			height: '20'
		}
	},
]

*/
<template>
  <canvas
    :style="{ width: width+'px', height: height+'px' }"
    @click="sendEvent()"
    @contextmenu.prevent="sendEventContext()"
    :width="width + 'px'"
    :height="height + 'px'"
    @mousemove="update($event)"
    @mouseout="update(false)"/>
</template>
<script>

export default {
  props: {
    menu: {
      type: Array,
      required: true
    },
    width: {
      type: String,
      required: true
    },
    height: {
      type: String,
      required: true
    },
    maxAngle: {
      type: Number,
      default: 360
    },
    space: {
      type: Number,
      default: 4
    },
    linebreak: {
      type: Boolean,
      default: true
    },
    lineheight: {
      type: [String, Number],
      default: 15
    },
    iconDistance: {
      type: Number,
      default: 22
    },
    color: {
      type: Object,
      default: function () {
        return {
          text: '#000000',
          background: '#FFFFFF',
          backgroundHover: '#CACACA',
          backgroundSelected: '#A0A0A0'
        }
      }
    },
    colorCount: {
      type: Object,
      default: function () {
        return {
          background: '#006ebf',
          text: '#FFFFFF'
        }
      }
    },
    circleStyle: {
      type: Object,
      default: () => {
        return {
          text: '#FFFFFF',
          background: 'yellow',
          backgroundHover: 'yellow'
        }
      }
    }
  },
  data: function () {
    return {
      padding: (this.menu.length > 1 ? this.space : 0),
      ctx: undefined,
      segmentWidth: ((this.maxAngle - this.getAngleSizeFromObjects(this.menu)) / this.getSlicesWithDefaultSize(this.menu)),
      optionSelected: undefined,
      optionMouseOver: undefined,
      circleIcon: undefined,
      icons: []
    }
  },
  mounted: function () {
    this.addFunctions()
    this.ctx = this.createCanvasContext()
    this.loadIcons()
    this.update(false)
  },
  watch: {
    menu: {
      handler () {
        this.padding = (this.menu.length > 1 ? this.space : 0)
        this.update(false)
      },
      deep: true
    },
    circleStyle: {
      handler () {
        this.update(false)
      },
      deep: true
    }
  },
  methods: {
    getPosition: function (e) {
      return {
        x: e.offsetX,
        y: e.offsetY
      }
    },
    loadIcons: function () {
      const that = this
      this.menu.forEach(function (item, index) {
        if (item.hasOwnProperty('icon') && item.icon && item.icon['url']) {
          that.icons[index] = that.loadIcon(item)
        }
      })
      if (this.circleStyle.hasOwnProperty('icon')) {
        this.circleIcon = that.loadIcon(this.circleStyle)
      }
    },
    loadIcon (item) {
      const that = this
      let icon = {}
      icon['image'] = new Image()
      icon['loaded'] = false
      icon['image'].addEventListener('load', function () {
        icon['loaded'] = true
        icon['width'] = item.icon['width'] ? item.icon.width : icon['image'].width
        icon['height'] = item.icon['height'] ? item.icon.height : icon['image'].height
        that.update(false)
      }, false)
      icon['image'].src = item.icon.url
      return icon
    },
    getAngleSizeFromObjects(menu) {
      let angleSizes = 0
      menu.forEach(item => {
        if(item.hasOwnProperty('size')) {
          angleSizes = angleSizes + item.size
        }
      })
      return angleSizes
    },
    getSlicesWithDefaultSize(menu) {
      let count = 0
      menu.forEach(item => {
        if(!item.hasOwnProperty('size')) {
          count = count +1
        }
      })
      return count      
    },
    createImage: function (src) {
      let image = new Image()
      image.src = src
      return image
    },
    createCanvasContext: function () {
      var canvas = this.$el
      var ctx = canvas.getContext('2d')

      if (window.devicePixelRatio > 1) {
        var canvasWidth = canvas.width
        var canvasHeight = canvas.height

        canvas.width = canvasWidth * window.devicePixelRatio
        canvas.height = canvasHeight * window.devicePixelRatio
        canvas.style.width = canvasWidth
        canvas.style.height = canvasHeight

        ctx.scale(window.devicePixelRatio, window.devicePixelRatio)
      }
      return ctx
    },
    addFunctions: function () {
      Math.radians = function (degrees) {
        return degrees * Math.PI / 180
      }

      Math.degrees = function (radians) {
        return radians * 180 / Math.PI
      };

      (function () {
        var annulus = function (centerX, centerY,
					                       innerRadius, outerRadius,
					                       startAngle, endAngle,
					                       anticlockwise) {
        var th1 = startAngle
        var th2 = endAngle
        var startOfOuterArcX = outerRadius * Math.cos(th2) + centerX
        var startOfOuterArcY = outerRadius * Math.sin(th2) + centerY

        this.beginPath()
        this.arc(centerX, centerY, innerRadius, th1, th2, anticlockwise)
        this.lineTo(startOfOuterArcX, startOfOuterArcY)
        this.arc(centerX, centerY, outerRadius, th2, th1, !anticlockwise)
        this.closePath()
        }
      CanvasRenderingContext2D.prototype.annulus = annulus
      })()
    },
    findNewPoint: function (x, y, angle, distance) {
      var result = {}

      result.x = Math.round(Math.cos(angle * Math.PI / 180) * distance + x)
      result.y = Math.round(Math.sin(angle * Math.PI / 180) * distance + y)

      return result
    },
    sendEvent: function () {
      this.optionSelected = this.optionMouseOver
      if (this.optionSelected) {
        this.$emit('selected', this.optionSelected.event)
        this.update(false)
      }
    },
    sendEventContext: function () {
      this.optionSelected = this.optionMouseOver
      if (this.optionSelected) {
        this.$emit('contextmenu', this.optionSelected.event)
        this.update(false)
      }
    },
    drawCircle: function (colorStyle = 'yellow') {
      this.ctx.fillStyle = colorStyle
      this.ctx.beginPath()
      this.ctx.arc(this.width / 2, this.height / 2, 30, 0, 2 * Math.PI, false)
      this.ctx.fill()
      this.ctx.closePath()
      if (this.circleStyle['icon']) {
        this.ctx.beginPath()
        this.ctx.drawImage(this.circleIcon.image, (this.width / 2 - this.circleIcon.width / 2), (this.height / 2 - this.circleIcon.height / 2), this.circleIcon.width, this.circleIcon.height)
        this.ctx.closePath()
      }
    },
    drawOption: function (color, angle, startPosition, endPosition, segmentWidth) {
      var positionArcCount = this.findNewPoint(this.width / 2, this.height / 2, Math.degrees(angle) + ((segmentWidth + (this.padding )) / 2), this.padding)

      this.ctx.beginPath()
      this.ctx.annulus(positionArcCount.x, positionArcCount.y, startPosition, endPosition, angle, angle + Math.radians(segmentWidth), false)
      this.ctx.fillStyle = color
      this.ctx.fill()
      this.ctx.closePath()
    },
    drawText (position, text, colorText) {
      this.ctx.beginPath()
      this.ctx.textAlign = 'center'
      this.ctx.textBaseline = 'middle'
      this.ctx.fillStyle = colorText
      this.ctx.font = '11px Arial'
      if(this.linebreak && text.toString().split(' ').length > 1) {
        let lines = text.toString().split(' ');
        for (var i = 0; i<lines.length; i++)
          this.ctx.fillText(lines[i], position.x, (position.y + (i*this.lineheight)));
      }
      else {
        this.ctx.fillText(text, position.x, position.y)
      }
      this.ctx.closePath()
    },
    isInside: function (E, position, segmentWidth) {
      if (E === false) return
      var width = this.width,
        height = this.height,
        angle = Math.radians(this.getSegmentSize(position)),
        mx = (E ? this.getPosition(E).x : width / 2),
        my = (E ? this.getPosition(E).y : height / 2)

      var mangle = (-Math.atan2(mx - width / 2, my - height / 2) + Math.PI * 2.5) % (Math.PI * 2)
      var mradius = Math.sqrt(Math.pow(mx - width / 2, 2) + Math.pow(my - height / 2, 2))

      if (((mangle > angle && mangle < (angle + Math.radians(segmentWidth))) || (mangle > Math.PI * (this.getSlicesWithDefaultSize(this.menu) * 2) / this.getSlicesWithDefaultSize(this.menu) && position == 0)) && mradius <= width / 2 && mradius >= 44) {
        return true
      } else {
        return false
      }
    },
    isInsideCircle(E, radius) {
      const centerX = this.width / 2
      const centerY = this.height / 2
      const a = centerX - this.getPosition(E).x;
      const b = centerY - this.getPosition(E).y;

      return Math.sqrt(a * a + b * b) < radius
    },
    getSegmentSize(position) {
      let size = 0
      
      for(var i = 0; i < position; i++) {
        size = size + (this.menu[i].hasOwnProperty('size') ? this.menu[i].size : this.segmentWidth)
      }
      
      return size
    },
    update: function (E) {
      var width = this.width,
        height = this.height,
        slices = this.menu.length

      if (E == false) {
        this.optionMouseOver = undefined
      }

      this.$el.style.cursor = 'initial'
      this.ctx.clearRect(0, 0, width, height)
      if (this.isInsideCircle(E, 30)) {
        this.drawCircle(this.circleStyle.backgroundHover)
        this.$el.style.cursor = 'pointer'
        this.optionMouseOver = { event: 'circleButton' }
      }
      else {
        this.drawCircle(this.circleStyle.background)
      }

      for (var i = 0; i < slices; i++) {
        var segmentWidth = (this.menu[i].hasOwnProperty('size') ? this.menu[i].size : this.segmentWidth)
        var angle = Math.radians(this.getSegmentSize(i))

        if (this.menu[i]['total']) {
          this.drawOption(this.colorCount.background, angle, this.width / 2 - 30, this.width / 2 - 4, segmentWidth)
          this.drawText(this.findNewPoint(this.width / 2, this.height / 2, Math.degrees(angle) + ((segmentWidth) / 2), this.width / 2 - 14), this.menu[i].total, this.colorCount.text)
        }

        if (this.optionSelected == this.menu[i]) {
          this.drawOption(this.color.backgroundSelected, angle, 40, this.width / 2 - 40, segmentWidth)
        } else if (this.isInside(E, i, segmentWidth)) {
          this.drawOption(this.color.backgroundHover, angle, 40, this.width / 2 - 40, segmentWidth)
          this.optionMouseOver = this.menu[i]
          this.$el.style.cursor = 'pointer'
        } else {
          this.drawOption(this.color.background, angle, 40, this.width / 2 - 40, segmentWidth)
        }

        let position = this.findNewPoint(this.width / 2, this.height / 2, Math.degrees(angle) + ((segmentWidth) / 2), this.width / 3.5)
        position.y = position.y - this.centerMenuOption(i)/2
        this.drawIcon(i, position)
        
        this.drawText(position, this.menu[i].label, this.color.text)
      }
    },
    drawIcon(sliceIndex, position) {
      if (this.icons[sliceIndex] && this.icons[sliceIndex].loaded) {
        let icon = this.icons[sliceIndex]
        let positionY = position.y - icon.height/2
        this.ctx.drawImage(icon.image, (position.x - icon.width / 2), positionY, icon.width, icon.height)
        position.y = position.y + this.iconDistance
      }
    },
    centerMenuOption(sliceIndex) {
      let height = 0
      if (this.icons[sliceIndex] && this.icons[sliceIndex].loaded) {
        height = Number(this.icons[sliceIndex].height)
      }
      if(this.linebreak && this.menu[sliceIndex].label.toString().split(' ').length > 1) {
        height = height + (this.lineheight * this.menu[sliceIndex].label.toString().split(' ').length)
      }
      return height
    }
  }
}

</script>
