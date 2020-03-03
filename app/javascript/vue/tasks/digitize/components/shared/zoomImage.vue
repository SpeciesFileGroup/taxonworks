<template>
  <div>
    <button
      type="button"
      @click="show = true">
      Zoom
    </button>
    <div
      v-if="show"
      class="depiction-zoom-container">
      <img
        v-if="image"
        :src="image.src"
        :width="`${width}px`"
        :height="`${height}px`">
      <div
        data-icon="close" class="close"
        @click="show = false">
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    imageUrl: {
      type: String,
      required: true
    },
  },
  data () {
    return {
      show: false,
      image: undefined,
      width: undefined,
      height: undefined
    }
  },
  watch: {
    show (newVal) {
      if (this.image) return
      let that = this
      let image = new Image()
      
      image.onload = () => {
        that.width = image.width
        that.height = image.height
        that.image = image
      }
      image.src = this.imageUrl
    }
  }
}
</script>

<style lang="scss">
  .depiction-zoom-container {
    position: fixed;
    top: 0px;
    left: 50%;
    transform: translateX(-50%);
    background-color: white;
    box-shadow: 0px 2px 4px 1px rgba(0,0,0,0.2);
    z-index: 500;
    line-height: 0px;
    .close {
      padding: 0px;
      position: absolute;
      width: 40px;
      height: 40px;
      background-color: white;
      border-radius: 50%;
      box-shadow: 0px 2px 2px 2px rgba(0,0,0,0.2);
      right: -20px;
      top: 50%;
      transform: translateY(-50%);
      background-position: center;
      cursor: pointer;
    }
  }
</style>