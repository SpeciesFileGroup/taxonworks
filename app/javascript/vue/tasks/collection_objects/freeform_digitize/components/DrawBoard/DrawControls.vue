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
        v-if="typeof item.icon === 'string'"
        small
        :name="item.icon"
      />
      <IconCircle v-else />
    </VBtn>

    <input
      type="color"
      @change="(e) => SVGBoard.apiStroke(e.target.value)"
    />
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { drawMode } from '@sfgrp/svg-detailer'
import useStore from '../../store/board.js'
import VIcon from '@/components/ui/VIcon/index.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import IconCircle from '@/components/Icon/IconCircle.vue'

const store = useStore()
const SVGBoard = computed(() => store.SVGBoard)

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

  [drawMode.CIRCLE]: {
    title: 'Circle',
    icon: IconCircle,
    action: () => SVGBoard.value.apiSetMode(drawMode.CIRCLE)
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
