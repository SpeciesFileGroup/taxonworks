<template>
  <div>
    <button @click="() => (mode = 'pan')">Pan</button>
    <button @click="() => (mode = 'measure')">Measure</button>
    <button @click="() => (mode = 'erase')">Erase</button>
    <button @click="() => (mode = 'zoom')">Zoom</button>
  </div>
</template>

<script setup>
const mode = defineModel({ default: 'pan' })
</script>
