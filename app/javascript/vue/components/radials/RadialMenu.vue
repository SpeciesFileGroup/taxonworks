<template>
  <div ref="radialContainer" />
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import RadialMenu from '@sfgrp/svg-radial-menu'

const props = defineProps({
  options: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['onClick'])

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
  radialInstance.on('click', (event) => emit('onClick', event))
}
</script>
