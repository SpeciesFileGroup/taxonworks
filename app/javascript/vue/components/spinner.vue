/*
	target: sets the parent DOM Element
	logoSize: sets the size of the logo
	legend: sets the legend description
	showSpinner: disable the spinner animation
	show-legend: activate the legend
*/

<template>
  <transition name="fade">
    <div class="middle box-spinner mx-spinner" :style="cssProperties">
      <div
        class="tw-spinner"
        :class="[`tw-spinner-${spinnerPosition}`]">
        <svg version="1.1" id="tw-spinner-logo" v-if="showSpinner" :style="logoSize" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"
             viewBox="0 0 194.6 200" style="enable-background:new 0 0 194.6 200;" xml:space="preserve">
          <path class="st0" id="LeftTop" d="M14.2,63.1C24.3,63.1,28,76.3,28,76.3s5,15.5,15.3,15.5c7.7,0,9.4-6.3,9.8-9.1c0-0.1,0-0.2,0-0.4s0-0.5,0.1-0.8
                              c0-0.1,0-0.1,0-0.2c0.3-2-0.8-4-2.7-4.8l0,0c-3.1-1.1-5.9-3-8-5.6c-6.4-7.4-3-17,4.5-23.6c-3.5-4-8-8.7-12-10.8
                              c-8.7-4.6-15.7,2.6-16.2,3.2L18.7,40c-0.6,0.8-1.2,1.6-1.8,2.5l-0.1,0.1c-0.6,0.9-1.2,1.8-1.8,2.7L15,45.4c-0.5,0.8-1,1.6-1.5,2.4
                              l-0.3,0.5c-1,1.8-2,3.6-3,5.5L10,54.3c-0.4,0.9-0.9,1.8-1.3,2.7l-0.1,0.1C8.2,58,7.8,59,7.4,59.9l-0.2,0.5c-0.3,0.8-0.6,1.5-0.9,2.3
                              l-0.2,0.6c-0.4,1-0.7,1.9-1,2.9L5,66.7c-0.1,0.3-0.2,0.5-0.2,0.8C7.1,64.7,10.5,63.1,14.2,63.1z"/>
          <path id="Head" class="st0" d="M36.2,33c5.3,1.8,11.4,6.8,15.7,11c0.5-0.3,1.1-0.6,1.6-0.9c2.3-1.2,4.7-2.1,7.2-2.7
                              c-2.4-4.9-5.6-12.8-4.9-18.3c1.4-11.2,13.6-12,13.6-12S58.3,12.5,59,22.9c0.3,5,4.7,12.5,7.5,16.8c7-0.1,13,2.7,15.8,8
                              c0.3,0.5,0.5,1.1,0.7,1.6l0,0c0.5,1,1.3,1.9,2.3,2.4c3.6,1.2,7.6,2.5,11.7,4.2c5.8,2.3,11.5,5,17,8.1c0.5,0.2,1,0,1.2-0.5
                              c0.1-0.3,0.1-0.7-0.2-0.9c-27.2-26.1-8-36.3-8-36.3c-9.8,14.2,6.6,24.5,25.5,35.1c16.6,9.3,28.4,19.5,41.3,12.7
                              c6.4-3.4,1.9-11-1-15.2c-2.2-2.9-4-6-5.6-9.2c-1-2.1-1.3-4.4-0.8-6.6c0.7-3.1-0.4-6.8-2.8-10.5c-1.8-2.8-5.1-5.7-7.6-7.6
                              c-1.6-1.3-3.1-2.7-4.3-4.4c-9-12.6-32.2-17.9-32.2-17.9l0,0C97.5-2.6,74.3,0.1,54,10.2l0,0c-6.9,3.5-13.5,7.7-19.4,12.7l-0.8,0.6
                              c-1.4,1.2-2.8,2.5-4.2,3.8l0,0c-0.8,0.8-1.6,1.5-2.3,2.3l0,0c-1.5,1.6-3,3.2-4.4,4.9l-0.2,0.2l-0.4,0.5C25.2,32.8,29.6,30.9,36.2,33
                              z M145.8,33.9c3.9-1.7,8.5,0.1,10.2,4c0.6,1.3,0.8,2.7,0.6,4c-2.5,1.2-5.5,0.9-7.7-0.9C146.5,39.5,145.3,36.7,145.8,33.9L145.8,33.9
                              z"/>
          <path id="LeftMid" class="st0" d="M53.2,106.9c-0.2-2-0.4-4-0.4-6.3c-2.3,1-4.7,1.5-7.2,1.5c-19,0-19.5-18.8-26.2-29.2
                              c-7-10.8-16.8,0.9-17.8,7.2c0,0.3-0.1,0.5-0.1,0.7c-0.1,0.6-0.2,1.3-0.3,1.9C1,83.1,1,83.4,1,83.6c-0.1,0.8-0.2,1.6-0.3,2.3
                              c0,0.3-0.1,0.5-0.1,0.8c-0.1,1-0.2,2.1-0.3,3.1c0,0.1,0,0.2,0,0.3c-0.1,0.9-0.2,1.9-0.2,2.8c0,0.3,0,0.6,0,0.9C0,94.9,0,95.8,0,96.7
                              c0,0.1,0,0.2,0,0.3s0,0.1,0,0.1s0,0.1,0,0.1c0,0.4,0,0.8,0,1.2s0,0.8,0,1.2c0,0.6,0,1.2,0.1,1.7c0,0.2,0,0.5,0,0.7
                              c1.5,30.7,17.5,58.9,43,76c-8-7.8-12.7-17.8-12.7-28.6c0-13.4,7.3-26,19.1-34.4C52,113.2,53.5,110.1,53.2,106.9z"/>
          <path id="LeftBottom" class="st0" d="M128.3,170c-5.8,2.4-12,3.9-18.3,4.4c-1.1,0.1-2.2,0.1-3.3,0.1c-12.3,0-28.4-4.8-40.7-25.3
                              l-1.6-2.7c-1.9,2.7-2.9,6-2.9,9.3c0,13.9,16.6,26.5,36.7,26.5c5.4,0.1,10.7-0.6,15.9-2c-4.6,2.9-13.8,5.6-21.9,5.6
                              C69.2,186,50,170.8,50,152.7c0.1-6.3,2.1-12.5,5.8-17.6c1.5-2.1,1.9-4.8,1.1-7.2l0,0c-10.5,6.1-17,15.4-17,26.6
                              c0,17.2,15.3,31.9,37,37.9c1.2,0.3,2.5,0.5,3.7,0.7c15.6,2.6,29.5-0.1,38.9-9.1C123.5,180.1,126.5,175.3,128.3,170z"/>
          <path id="Tail" class="st0" d="M171,33.8c28,39.3,18.8,93.8-20.5,121.8c-2.4,1.7-4.9,3.3-7.5,4.8l-0.2,0.2c0-0.4,0-0.9,0.1-1.3
                              c0.6-3.9,2.1-7.6,4.4-10.8c7.5-10.7,12.4-27-0.3-48.1c-7-11.6-21.7-28-51.7-40.1c-4.1-1.7-8.1-3.1-11.8-4.2L82,55.6l-0.2-0.1
                              c-1.1-0.3-2.1-0.6-3.1-0.9h-0.2l-2.9-0.8h-0.1l-1.3-0.3h-0.1l-2.6-0.6h-0.1l-2.3-0.5h-0.2l-1-0.2l0,0L67,51.7h-0.2l-0.7-0.2h-0.2
                              l-0.8-0.2H65l-0.6-0.1h-0.2L63.7,51l-0.1,0.4v0.1l-0.1,0.3l0,0.2l-0.1,0.3l-0.1,0.2l-0.1,0.3l-0.1,0.2L63,53.5L63,53.7l-0.1,0.4
                              l-0.1,0.2l-0.1,0.5l-0.1,0.3l-0.1,0.6L62.3,56l-0.1,0.5l-0.1,0.3L62,57.2l-0.1,0.4L61.8,58l-0.1,0.4l-0.1,0.5l-0.1,0.4l-0.1,0.5
                              l-0.1,0.4l-0.1,0.6l-0.1,0.5L61,61.9l-0.1,0.4l-0.1,0.5l-0.1,0.5l-0.1,0.5l-0.1,0.5l-0.1,0.5l-0.1,0.5l-0.1,0.5l-0.1,0.5L60,66.9
                              l-0.1,0.5l-0.1,0.7l-0.1,0.5l-0.2,1l-0.1,0.5l-0.1,0.6l-0.1,0.5l-0.1,0.6l-0.1,0.6L59,73.1l-0.1,0.6l-0.1,0.6l-0.1,0.6l-0.1,0.7
                              l-0.1,0.6l-0.1,0.8l-0.1,0.5c-0.2,1.8-0.4,3.6-0.6,5.5V83c0,0.6-0.1,1.1-0.1,1.7l0,0c0,0.6-0.1,1.1-0.1,1.7v0.1
                              c0,0.6-0.1,1.1-0.1,1.7l0,0c-0.2,3-0.2,6.2-0.2,9.5c0.1,4.3,0.4,8.5,0.8,12.7c0,0.3,0.1,0.7,0.1,1.1c0.7,5.8,1.9,11.4,3.6,17
                              c1.5,4.5,3.2,8.9,5.2,13.2c0.9,1.7,1.8,3.4,2.8,5.1c9.2,15.3,21.5,23,36.6,23c1,0,2.1,0,3.2-0.1c7-0.6,13.9-2.5,20.2-5.6
                              c4.9-24.5-8.4-59.3-36.1-88.3C90,71.8,86,68,81.7,64.4c9.2,6.9,13.9,10.7,19.2,16.3c37.8,39.6,49.7,89.7,26.5,111.9
                              c-3.4,3.3-7.5,5.8-11.9,7.5c5.8-1.6,11.1-4.5,15.4-8.6c1.4-1.3,2.6-2.7,3.8-4.2c49.6-20.7,73-77.7,52.4-127.3
                              C183.1,50.4,177.7,41.6,171,33.8z"/>
        </svg>
        <span v-if="showLegend" :style="legendStyle"> {{ legend }} </span>
      </div>
    </div>
  </transition>
</template>

<script>
export default {
  props: {
    target: {
      type: String,
      default: undefined
    },

    fullScreen: {
      type: Boolean,
      default: false
    },

    legend: {
      type: String,
      default: 'Loading, please wait.'
    },

    resize: {
      default: true
    },

    legendStyle: {
      type: Object,
      default: () =>
        ({
          color: '#444',
          marginTop: '30px',
          textAlign: 'center'
        })
    },

    showLegend: {
      type: Boolean,
      default: true
    },

    showSpinner: {
      type: Boolean,
      default: true
    },
    spinnerPosition: {
      type: String,
      default: 'top'
    },

    logoSize: {
      type: Object,
      default: () => ({
        width: '50px',
        height: '50px'
      })
    }
  },

  data: () => ({
    cssProperties: {
      width: undefined,
      height: undefined,
      position: 'absolute',
      top: undefined,
      zIndex: undefined,
      left: undefined
    },
    resizeInterval: undefined
  }),

  mounted () {
    this.init()
    if (this.resize && !this.fullScreen) {
      this.checkResize()
    }
  },

  unmounted () {
    clearInterval(this.resizeInterval)
  },

  methods: {
    outerWidth (el) {
      const style = getComputedStyle(el)
      let width = el.offsetWidth

      width += parseInt(style.marginLeft) + parseInt(style.marginRight)
      return width
    },
    outerHeight (el) {
      const style = getComputedStyle(el)
      let height = el.offsetHeight

      height += parseInt(style.marginTop) + parseInt(style.marginBottom)
      return height
    },
    init () {
      const domElement = this.target != undefined ? this.loadElement(this.target) : this.$el.parentNode
      const copyCSS = Object.assign({}, this.cssProperties)

      if (this.fullScreen) {
        copyCSS.position = 'fixed'
        copyCSS.width = '100vw'
        copyCSS.height = '100vh'
        copyCSS.top = '0px'
        copyCSS.left = '0px'
      } else {
        copyCSS.width = this.outerWidth(domElement) + 'px'
        copyCSS.height = this.outerHeight(domElement) + 'px'
        copyCSS.top = domElement.getBoundingClientRect().top
        copyCSS.left = domElement.getBoundingClientRect().left
      }
      if (!this.showSpinner) {
        copyCSS.zIndex = (domElement.style.zIndex == '' ? 2 : (domElement.style.zIndex + 1))
      }
      this.cssProperties = copyCSS
    },

    loadElement (el) {
      let domElement

      switch (el.substring(0, 1)) {
        case '#':
          domElement = document.getElementById(el.substring(1))
          break
        case '.':
          domElement = document.getElementsByClassName(el.substring(1))
          break
        default:
          domElement = document.getElementsByTagName(el)[0]
      }
      return domElement
    },

    checkResize () {
      this.resizeInterval = setInterval(() => {
        this.init()
      }, 500)
    }
  }
}
</script>
<style>
  .tw-spinner {
    display: flex;
    margin: 0 auto;
    height: auto;
    width: auto;
    align-items: center;
  }
  .fade-enter-active, .fade-leave-active {
    transition: opacity .5s
  }
  .fade-enter, .fade-leave-to {
    opacity: 0
  }

  .tw-spinner-left {
    flex-direction: row;
  }

  .tw-spinner-right {
    flex-direction: row-reverse;
  }

  .tw-spinner-top {
    flex-direction: column;
  }

  .tw-spinner-bottom {
    flex-direction: column-reverse;
  }

</style>
