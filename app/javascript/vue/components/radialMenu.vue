/*

menu structure:
[
	{
		label: 'Citation',
		total: 11,
		event: 'citation',
		icon: {
			url: 'image.svg',
			width: '20',
			height: '20'
		}
	},
]

*/
<template>
  <canvas :style="{ width: width+'px', height: height+'px' }" @click="sendEvent()" :width="width + 'px'" :height="height + 'px'" @mousemove="update($event)" @mouseout="update(false)"/>
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
    }
  },
  data: function () {
    return {
      padding: (this.menu.length > 1 ? this.space : 0),
      ctx: undefined,
      segmentWidth: this.maxAngle / this.menu.length,
      optionSelected: undefined,
      optionMouseOver: undefined,
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
      handler: function () {
        this.padding = (this.menu.length > 1 ? this.space : 0)
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
      var that = this
			    this.menu.forEach(function (item, index) {
			    	if (item.hasOwnProperty('icon')) {
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
			    			that.icons.push(icon)
			    	} else {
			    		that.icons.push(undefined)
			    	}
			    })
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
    drawCircle: function () {
			    this.ctx.fillStyle = 'yellow'
			    this.ctx.beginPath()
			    this.ctx.arc(this.width / 2, this.height / 2, 30, 0, 2 * Math.PI, false)
			    this.ctx.fill()
			    this.ctx.closePath()
    },
    drawOption: function (color, angle, startPosition, endPosition) {
      var positionArcCount = this.findNewPoint(this.width / 2, this.height / 2, Math.degrees(angle) + ((this.segmentWidth + (this.padding / 2)) / 2), this.padding)

			        this.ctx.beginPath()
			        this.ctx.annulus(positionArcCount.x, positionArcCount.y, startPosition, endPosition, angle, angle + Math.radians(this.segmentWidth), false)
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
      if(this.linebreak) {
        let lineheight = 15;
        let lines = text.toString().split(' ');
        for (var i = 0; i<lines.length; i++)
          this.ctx.fillText(lines[i], position.x, position.y + (i*lineheight) );
      }
      else {
        this.ctx.fillText(text, position.x, position.y)
      }
      this.ctx.closePath()
    },
    isInside: function (E, position) {
      if (E === false) return
      var width = this.width,
        height = this.height,
        angle = Math.radians(this.segmentWidth * position),
			        mx = (E ? this.getPosition(E).x : width / 2),
			        my = (E ? this.getPosition(E).y : height / 2)

			    	var mangle = (-Math.atan2(mx - width / 2, my - height / 2) + Math.PI * 2.5) % (Math.PI * 2)
			    	var mradius = Math.sqrt(Math.pow(mx - width / 2, 2) + Math.pow(my - height / 2, 2))

      if (((mangle > angle && mangle < (angle + Math.radians(this.segmentWidth))) || (mangle > Math.PI * (this.menu.length * 2) / this.menu.length && position == 0)) && mradius <= width / 2 && mradius >= 50) {
			            return true
			        } else {
			            return false
      }
    },
    update: function (E) {
			    var width = this.width,
			        height = this.height,
			        slices = this.menu.length,
			        segmentWidth = this.segmentWidth

			    if (E == false) {
			    	this.optionMouseOver = undefined
			    }

      this.$el.style.cursor = 'initial'
			    this.ctx.clearRect(0, 0, width, height)
      this.drawCircle()

			    for (var i = 0; i < slices; i++) {
			        var angle = Math.radians(segmentWidth * i)
			        if (this.menu[i]['total']) {
          this.drawOption('green', angle, this.width / 2 - 30, this.width / 2 - 4)
			        	this.drawText(this.findNewPoint(this.width / 2, this.height / 2, Math.degrees(angle) + ((this.segmentWidth) / 2), this.width / 2 - 14), this.menu[i].total, '#FFFFFF')
			    	}

			        if (this.optionSelected == this.menu[i]) {
			        	this.drawOption(this.color.backgroundSelected, angle, 40, this.width / 2 - 40)
			        } else if (this.isInside(E, i)) {
			            this.drawOption(this.color.backgroundHover, angle, 40, this.width / 2 - 40)
			            this.optionMouseOver = this.menu[i]
			            this.$el.style.cursor = 'pointer'
			        } else {
			            this.drawOption(this.color.background, angle, 40, this.width / 2 - 40)
			        }

			        let position = this.findNewPoint(this.width / 2, this.height / 2, Math.degrees(angle) + ((this.segmentWidth) / 2), this.width / 3.5)
			        if (this.icons[i] && this.icons[i].loaded) {
			        	let icon = this.icons[i]

          this.ctx.drawImage(icon.image, (position.x - icon.width / 2), (position.y - icon.height), icon.width, icon.height)
        }
        position.y = position.y + 14
        this.drawText(position, this.menu[i].label, this.color.text)
			    }
    }
  }
}

</script>
