<template>
  <div class="panel content flex-column draw__toolbar">
    <button
      type="button"
      @click="SVGBoard.apiSetMode(drawMode.CIRCLE)"
    >
      <svg
        width="24px"
        height="24px"
        viewBox="0 0 24 24"
        xmlns="http://www.w3.org/2000/svg"
      >
        <circle
          cx="12"
          cy="12"
          fill="none"
          r="10"
          stroke-width="2"
          stroke="currentColor"
          stroke-linecap="round"
          stroke-linejoin="round"
        />
      </svg>
    </button>
    <button
      type="button"
      @click="SVGBoard.apiSetMode(drawMode.RECTANGLE)"
    >
      <VIcon name="square" />
    </button>

    <button
      type="button"
      @click="SVGBoard.apiSetMode(drawMode.POLYGON)"
    >
      <VIcon name="polyline" />
    </button>

    <button
      type="button"
      @click="SVGBoard.apiZoomIn()"
    >
      <VIcon name="zoomIn" />
    </button>

    <button
      type="button"
      @click="SVGBoard.apiZoomOut()"
    >
      <VIcon name="zoomOut" />
    </button>

    <input
      type="color"
      v-model="color"
    >
  </div>
</template>

<script setup>
import { GetterNames } from '../../store/getters/getters'
import { computed, ref, watch } from 'vue'
import { useStore } from 'vuex'
import { drawMode } from '@sfgrp/svg-detailer'
import VIcon from 'components/ui/VIcon/index.vue'

const store = useStore()
const SVGBoard = computed(() => store.getters[GetterNames.GetSVGBoard])
const color = ref('#000000')

watch(
  color,
  (newVal) => {
    SVGBoard.value.apiStroke(newVal)
  }
)

</script>

<style scoped lang="scss">
.draw__toolbar {
  width: 40px;

  button {
    background-color: transparent;
    border: none;
    padding: .5rem;
    cursor: pointer;
  }

  input {
    border: none;
    width: auto;
    cursor: pointer;
  }
}
</style>
