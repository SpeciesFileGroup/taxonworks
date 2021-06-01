<template>
  <div
    ref="navBar"
    class="separate-bottom">
    <div class="panel">
      <div class="content">
        <slot></slot>
      </div>
    </div>
  </div>
</template>
<script>

export default {
  data () {
    return {
      position: undefined
    }
  },
  mounted () {
    this.position = this.$el.offsetTop
    window.addEventListener('scroll', this.setFixeable)
  },
  methods: {
    setFixeable () {
      if ((window.pageYOffset || document.documentElement.scrollTop || document.body.scrollTop || 0) > this.position) {
        this.$el.classList.add('navbar-fixed-top')
        this.$el.style.width = `${this.$el.parentElement.clientWidth}px`
      } else {
        this.$el.removeAttribute('style')
        this.$el.classList.remove('navbar-fixed-top')
      }
    }
  },
  destroyed () {
    window.removeEventListener('scroll', this.setFixeable)
  }
}
</script>
<style lang="scss" scoped>
  .navbar-fixed-top {
    top:0px;
    z-index:1001;
    width:inherit;
    position: fixed;
  }
</style>
