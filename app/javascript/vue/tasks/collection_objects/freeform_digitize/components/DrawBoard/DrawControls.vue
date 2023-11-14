<template>
  <div class="panel flex-column draw__toolbar gap-medium padding-medium">
    <VBtn
      v-for="(item, key) in TOOLS"
      class="no-padding"
      circle
      medium
      :class="{ 'border-active': key === store.SVGCurrentMode }"
      :key="key"
      :title="item.title"
      @click="item.action"
    >
      <VIcon
        small
        :name="item.icon"
      />
    </VBtn>

    <VBtn
      type="button"
      title="Circle"
      class="no-padding"
      @click="SVGBoard.apiSetMode(drawMode.CIRCLE)"
    >
      <svg
        width="16px"
        height="16px"
        viewBox="0 0 24 24"
        xmlns="http://www.w3.org/2000/svg"
      >
        <circle
          cx="12"
          cy="12"
          fill="none"
          r="11"
          stroke-width="2"
          stroke="currentColor"
          stroke-linecap="round"
          stroke-linejoin="round"
        />
      </svg>
    </VBtn>

    <input
      type="color"
      v-model="color"
    />
  </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { drawMode } from '@sfgrp/svg-detailer'
import useStore from '../../store/store'
import VIcon from '@/components/ui/VIcon/index.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const store = useStore()
const SVGBoard = computed(() => store.SVGBoard)
const color = ref('#000000')

const TOOLS = {
  [drawMode.MOVE]: {
    title: 'Move',
    icon: 'move',
    action: () => SVGBoard.value.apiSetMode(drawMode.MOVE)
  },
  [drawMode.RECTANGLE]: {
    title: 'Rectangle',
    icon: 'square',
    action: () => SVGBoard.value.apiSetMode(drawMode.RECTANGLE)
  },
  [drawMode.POLYGON]: {
    title: 'Polygon',
    icon: 'polyline',
    action: () => SVGBoard.value.apiSetMode(drawMode.POLYGON)
  },

  zoomIn: {
    title: 'Zoom in',
    icon: 'zoomIn',
    action: () => SVGBoard.value.apiZoomIn()
  },
  zoomOut: {
    title: 'Zoom out',
    icon: 'zoomOut',
    action: () => SVGBoard.value.apiZoomOut()
  }
}

watch(color, (newVal) => {
  SVGBoard.value.apiStroke(newVal)
})
</script>

<style scoped lang="scss">
.draw__toolbar {
  button {
    background-color: transparent;
    border: none;
    cursor: pointer;
  }

  input {
    border: none;
    padding: 0;
    width: 28px;
    cursor: pointer;
  }

  .border-active {
    border: 2px solid var(--color-primary);
  }
}
</style>
