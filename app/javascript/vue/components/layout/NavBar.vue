<template>
  <div
    class="separate-bottom"
    :style="barStyle"
    ref="navbar">
    <div class="panel">
      <div class="content">
        <slot />
      </div>
    </div>
  </div>
</template>
<script>

export default {
  props: {
    componentStyle: {
      type: Object,
      default: () => {
        return {
          top: '0',
          position: 'fixed',
          zIndex: 200
        }
      }
    }
  },
  computed: {
    barStyle () {
      return this.isFixed ? this.componentStyle : {}
    }
  },
  data () {
    return {
      position: undefined,
      isFixed: false,
      observeBody: undefined
    }
  },

  mounted () {
    this.position = this.$el.offsetTop
    this.observeBody = new ResizeObserver(this.setFixeable)
    this.observeBody.observe(document.body)
    window.addEventListener('scroll', this.setFixeable)
  },

  methods: {
    setFixeable () {
      if ((window.pageYOffset || document.documentElement.scrollTop || document.body.scrollTop || 0) > this.position) {
        this.$el.classList.add('navbar-fixed-top')
        this.$el.style.width = `${this.$el.parentElement.clientWidth}px`
        this.isFixed = true
      } else {
        this.isFixed = false
        this.$el.removeAttribute('style')
        this.$el.classList.remove('navbar-fixed-top')
      }
    }
  },

  unmounted () {
    window.removeEventListener('scroll', this.setFixeable)
    this.observeBody?.disconnect()
  }
}
</script>

<style lang="scss" scoped>
  .navbar-fixed-top {
    top:0px;
    z-index:1001;
    position: fixed;
  }
</style>
