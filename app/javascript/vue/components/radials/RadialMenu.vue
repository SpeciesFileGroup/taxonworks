<template>
  <div ref="radialContainer" />
</template>

<script>
const EVENTS = ['click', 'contextmenu', 'mousedown', 'mouseup', 'dblclick']
</script>

<script setup>
import { ref, onMounted, watch } from 'vue'
import RadialMenu from '@sfgrp/svg-radial-menu'

const props = defineProps({
  options: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(EVENTS)

const radialContainer = ref(null)
let radialInstance = null

watch(
  () => props.options,
  (newVal) => {
    if (newVal) {
      initRadialMenu()
    }
  }
)

onMounted(() => {
  initRadialMenu()
})

function initRadialMenu() {
  radialInstance = new RadialMenu(radialContainer.value, props.options)
  handleEvents()
}

function handleEvents() {
  EVENTS.forEach((eventName) => {
    radialInstance.on(eventName, (event) => emit(eventName, event))
  })
}
</script>
