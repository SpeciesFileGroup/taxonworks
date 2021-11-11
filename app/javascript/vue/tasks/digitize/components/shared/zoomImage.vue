<template>
  <div>
    <button
      type="button"
      class="button button-default button-circle"
      @click="show = true">
      <v-icon
        x-small
        color="white"
        name="expand"/>
    </button>
    <div
      v-if="show"
      class="depiction-zoom-container"
      :class="{ 'depiction-zoom-container-bottom': flip }">
      <img
        v-if="image"
        class="img-size"
        :src="image.src"
      >
      <div
        data-icon="close"
        class="btn-zoom close"
        @click="show = false"/>
      <div
        data-icon="swap"
        @click="flip = !flip"
        class="btn-zoom flip-button"/>
    </div>
  </div>
</template>

<script>

import VIcon from 'components/ui/VIcon/index'

export default {
  components: { VIcon },

  props: {
    imageUrl: {
      type: String,
      required: true
    }
  },

  data () {
    return {
      show: false,
      image: undefined,
      width: undefined,
      height: undefined,
      flip: false
    }
  },

  watch: {
    show (newVal) {
      if (this.image) return
      const image = new Image()

      image.onload = () => {
        this.width = image.width
        this.height = image.height
        this.image = image
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
    z-index: 1002;

    .img-size {
      max-width: 90vw;
      max-height: 50vh;
    }

    .btn-zoom {
      padding: 0px;
      position: absolute;
      width: 40px;
      height: 40px;
      background-color: white;
      border-radius: 50%;
      box-shadow: 0px 2px 2px 2px rgba(0,0,0,0.2);
    }
    .close {
      right: -20px;
      top: 50%;
      transform: translateY(-50%);
      background-position: center;
      cursor: pointer;
    }
    .flip-button {
      left: 50%;
      bottom: -20px;
      transform: translateX(-50%) rotate(90deg);
      background-size: 20px;
      background-position: center;
      cursor: pointer;
    }
  }
  .depiction-zoom-container-bottom {
    bottom: 0;
    top: auto;
    .flip-button {
      top: -20px;
      bottom: auto;
    }
  }
</style>