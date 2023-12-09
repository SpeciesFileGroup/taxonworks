<template>
  <div>
    <button
      type="button"
      class="button button-default button-circle"
      @click="() => (isVisible = true)"
    >
      <v-icon
        x-small
        color="white"
        name="expand"
      />
    </button>
    <div
      v-if="isVisible"
      class="depiction-zoom-container"
      :class="{ 'depiction-zoom-container-bottom': flip }"
    >
      <SvgViewer
        v-if="svgClip"
        class="img-size"
        :height="data.height"
        :width="data.width"
        :groups="svgClip"
        :image="{
          url: depiction.image.image_file_url,
          width: depiction.image.width,
          height: depiction.image.height
        }"
      />
      <img
        v-else
        class="img-size"
        :src="data.imageUrl"
      />
      <div
        data-icon="close"
        class="btn-zoom close"
        @click="isVisible = false"
      />
      <div
        data-icon="swap"
        @click="flip = !flip"
        class="btn-zoom flip-button"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import VIcon from '@/components/ui/VIcon/index'
import SvgViewer from '@/components/Svg/SvgViewer.vue'

const props = defineProps({
  data: {
    type: String,
    required: true
  },

  depiction: {
    type: Object,
    required: true
  }
})

const isVisible = ref(false)
const flip = ref(false)

const svgClip = computed(() => {
  return props.depiction?.svg_clip
    ? [
        {
          g: props.depiction.svg_clip,
          attributes: { fill: '#FFA500', 'fill-opacity': 0.25 }
        }
      ]
    : null
})
</script>

<style lang="scss">
.depiction-zoom-container {
  position: fixed;
  top: 0px;
  left: 50%;
  transform: translateX(-50%);
  background-color: white;
  box-shadow: 0px 2px 4px 1px rgba(0, 0, 0, 0.2);
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
    box-shadow: 0px 2px 2px 2px rgba(0, 0, 0, 0.2);
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
